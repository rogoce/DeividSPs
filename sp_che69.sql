-- Reporte para las requisiciones de Reclamos de Salud	en firma

-- Creado    : 24/07/2006 - Autor: Armando Moreno

drop procedure sp_che69;

create procedure sp_che69(a_cod_agente char(5) DEFAULT "*" )
 returning char(10),
		   char(10),
		   char(100),
		   dec(16,2),
		   smallint,
		   char(50),
		   char(8),
		   char(8),
		   smallint,
		   date,
		   smallint,
		   char(5),
		   varchar(50),
		   integer;

define _no_requis		char(10);
define _cod_cliente		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _fecha_captura   date;
define _dias            integer;
define _fecha_firma1	datetime year to fraction(5);
define _fecha_firma2	datetime year to fraction(5);
define _estatus			smallint;
define _fecha_time		datetime year to fraction(5);
define _fecha_hoy_time	datetime year to fraction(5);
define _wf_entregado    smallint;
define _cod_agente      char(5);
define _nombre_agente   varchar(50);
define _no_reclamo      char(10);
define _no_poliza       char(10);
define _no_cheque       integer;


let _fecha_hoy_time = CURRENT;

SET ISOLATION TO DIRTY READ;

select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

foreach
 select	no_requis,
		cod_cliente,
		monto,
		a_nombre_de,
		periodo_pago,
		firma1,
		firma2,
		fecha_impresion,
		fecha_firma1,
		fecha_firma2,
		fecha_paso_firma,
		wf_entregado,
		no_cheque
   into	_no_requis,
		_cod_cliente,
		_monto,
		_a_nombre_de,
		_periodo_pago,
		_firma1,
		_firma2,
		_fecha_captura,
		_fecha_firma1,
		_fecha_firma2,
		_fecha_time,
		_wf_entregado,
		_no_cheque
   from	chqchmae
  where origen_cheque = "3"
    AND ((incidente is not null 
    AND   incidente <> 0 
    AND  wf_firmado = 1 
    AND (anulado <> 1 
     OR  anulado is NULL)) 
     OR (en_firma = 2 
    AND  pagado = 1 
    AND (anulado <> 1 
     OR  anulado is NULL)))
 order by fecha_impresion

 let _estatus = 0;

 foreach
	select cod_tipopago,
	       no_reclamo
	  into _cod_tipopago,
	       _no_reclamo
	  from rectrmae
	 where no_requis = _no_requis

	exit foreach;
 end foreach

If _cod_tipopago <> "003" Then
   continue foreach;
End If    

 select nombre
   into _nom_tipopago
   from rectipag
  where cod_tipopago = _cod_tipopago;

 select no_poliza
   into _no_poliza
   from recrcmae
  where no_reclamo = _no_reclamo;

 foreach
 	select cod_agente 
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza

    If a_cod_agente <> '*' Then
		If a_cod_agente <> _cod_agente Then
			continue foreach;
		End IF
	End If 

    select nombre
      into _nombre_agente
      from agtagent
     where cod_agente = _cod_agente; 

	return _no_requis,
		   _cod_cliente,
		   _a_nombre_de,
		   _monto,
		   _periodo_pago,
		   _nom_tipopago,
		   _firma1,
		   _firma2,
		   _estatus,
		   _fecha_captura,
		   _wf_entregado,
		   _cod_agente,
		   _nombre_agente,
		   _no_cheque
		   with resume;
 end foreach

end foreach

end procedure
