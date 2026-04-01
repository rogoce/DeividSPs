-- Procedure que cierra los reclamos abiertos hace mas de 3 meses que no han tenido movimiento

drop procedure sp_atc31;

create procedure sp_atc31(a_fecha DATE default today, a_fecha2 DATE default today)
returning varchar(100) as asegurado,
		  char(30) as email,
		  char(10) as celular,
		  char(10) as telefono1,
		  char(10) as telefono2,
		  char(10) as telefono3,
		  char(20) as reclamo,
          date as fecha_reclamo,
          date as fecha_siniestro,
          date as fecha_cheque,	  
          char(18) as poliza,
		  varchar(50) as corredor,
		  char(10) as tipo_requis,
		  char(10) as estatus_reclamo;

define _fecha_siniestro	date;
define _fecha_reclamo	date;
define _fecha_cheque    date;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _no_poliza		char(10);

define _no_documento    char(20);
define _nombre          char(100);
define _e_mail          char(30);

define _tipo_requis     char(1);
define _cod_cliente     char(10);

define _celular         char(10);
define _telefono1		char(10);   
define _telefono2       char(10);
define _telefono3       char(10);

define _cod_agente      char(5);
define _agente          varchar(50);
define _estatus_reclamo char(1);

set isolation to dirty read;

foreach
	select distinct c.no_reclamo,
	       b.tipo_requis,
		   c.cod_cliente,
		   b.fecha_impresion
	  into _no_reclamo,
           _tipo_requis,
           _cod_cliente,
           _fecha_cheque		   
      from chqchrec a, chqchmae b, rectrmae c
     where a.no_requis = b.no_requis
	   and a.transaccion = c.transaccion
       and b.origen_cheque = '3'
       and b.pagado = 1
	   and b.anulado = 0
	   and b.cod_banco <> '295'
	   and c.cod_tipopago = '003'
       and ((b.tipo_requis = 'A' 
	   and fecha_impresion >= a_fecha
	   and fecha_impresion <= a_fecha2)
        or (b.tipo_requis = 'C'	
	   and  b.wf_entregado = 1
	   and  b.wf_fecha >= a_fecha
	   and  b.wf_fecha <= a_fecha2))   
	   
	select a.numrecla,
	       a.fecha_reclamo,
           a.fecha_siniestro,
		   a.no_poliza,
		   a.estatus_reclamo
	  into _numrecla,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   _no_poliza,
		   _estatus_reclamo
	   from recrcmae a
	  where a.no_reclamo = _no_reclamo;
	  
--	if _estatus_reclamo <> 'C' then -- Se puso en comentario para prueba Amado 12-04-2023
--		continue foreach;
--	end if	
	  
	select nombre,
           e_mail,
           celular,
           telefono1,		   
           telefono2,
		   telefono3
	  into _nombre,
           _e_mail,
           _celular,
           _telefono1,		   
           _telefono2,
		   _telefono3	
      from cliclien
     where cod_cliente = _cod_cliente;
  
    select no_documento
      into _no_documento
      from emipomae
     where no_poliza = _no_poliza;	 	

    foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

        exit foreach;		 
    end foreach		 
	
	select nombre
	  into _agente
	  from agtagent
	 where cod_agente = _cod_agente;
		   
	return _nombre,
	       _e_mail,
		   _celular,
           _telefono1,		   
           _telefono2,
		   _telefono3,	
		   _numrecla,
	       _fecha_reclamo,
		   _fecha_siniestro,
		   _fecha_cheque,
		   _no_documento,
		   _agente,
		   case when _tipo_requis = 'A' then 'ACH' else 'CHEQUE' end,
		   (case when _estatus_reclamo = "A" then "ABIERTO" else (case when _estatus_reclamo = "C" then "CERRADO" else (case when _estatus_reclamo = "D" then "DECLINADO" else "NO APLICA" end) end) end)
		   with resume;

end foreach

end procedure