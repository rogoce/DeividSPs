-- Consulta de Movimientos de Cuentas Sac x CHEQUES
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac155('121020402','COB12091','18/12/2009')

drop procedure ap_dif_sql;
create procedure ap_dif_sql(a_fecha date, a_fecha2 date) 
returning	char(10) as requisicion,		-- 	requisicion
            date as fecha,
            char(10) as cod_agente,
            varchar(50) as agente,    
            char(50) as descripcion, 
			date as anulado,
			dec(15,2) as debito,		-- 	debito
			dec(15,2) as credito,		-- 	credito
			dec(15,2) as mayor,		-- 	neto
			dec(15,2) as banco,
			dec(15,2) as diferencia,
			date as fecha_desde,
			date as fecha_hasta,
			char(10) as requis_compensa;			

define i_comprobante	char(15);
define i_cuenta			char(12);
define i_origen			char(12);
define d_requis			char(10);
define d_remesa			char(10);
define d_credito		dec(15,2);
define i_credito		dec(15,2);
define i_debito			dec(15,2);
define d_debito			dec(15,2);
define i_neto			dec(15,2);
define i_notrx			integer;
define i_fechatrx		date;
DEFINE v_comp			  CHAR(15);
DEFINE v_fecha			  DATE;
DEFINE v_tipo	          CHAR(3);
DEFINE v_origen           CHAR(3);
DEFINE v_descrip          CHAR(50);
DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);
DEFINE _monto             DEC(15,2);
define _origen_cheque     CHAR(1);
DEFINE _cod_agente        CHAR(10);
DEFINE _agente            VARCHAR(50);
DEFINE _fecha_desde       DATE;
DEFINE _fecha_hasta       DATE;
DEFINE _no_requis         CHAR(10);
DEFINE _dif               DEC(15,2);
DEFINE _fecha_anulado     DATE;
DEFINE _fecha_genera      DATE;

set isolation to dirty read;

create temp table tmp_asiento(
		cuenta		char(12),
		comprobante	char(15),
		fechatrx	date,
		notrx		integer,
		debito		dec(15,2)   default 0,
		credito		dec(15,2)   default 0,
		neto		dec(15,2)   default 0,
		origen		char(3),
		requis		char(10),
		descripcion CHAR(50)
		) with no log; 	

--  set debug file to "sp_sac155.trc";	
--  trace on;

foreach
 select res_comprobante,
 		res_fechatrx,
 		res_tipcomp,
 		res_origen,
		res_descripcion,
 		sum(res_debito),
 		sum(res_credito)
   into v_comp,
	    v_fecha,
	    v_tipo,
	    v_origen,
		v_descrip,
	    v_debito,
        v_credito
   from cglresumen
  where res_cuenta   >= '1220103'
	and	res_cuenta   <= '1220103'
    and res_fechatrx >= a_fecha
    and res_fechatrx <= a_fecha2
	and res_descripcion like '%ACH%'
	and res_origen = 'CHE'
  group by res_fechatrx, res_comprobante, res_tipcomp, res_origen, res_descripcion
  order by res_fechatrx, res_comprobante, res_tipcomp, res_origen, res_descripcion

foreach
	select res_notrx,
		   res_origen,
		   res_debito,
		   res_credito
	  into i_notrx,
		   i_origen,
		   i_debito,
		   i_credito
      from cglresumen
	 where res_cuenta		= '1220103'
	   and res_comprobante	= v_comp
	   and res_fechatrx		= v_fecha
	 order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen

	if i_origen in ('CHE','PLA') then

		foreach
			select no_requis,
				   sum(debito),
				   sum(credito) 
			  into d_requis,
			  	   d_debito,
			  	   d_credito
			  from deivid:chqchcta
			 where sac_notrx = i_notrx
			   and cuenta = '1220103'
			 group by no_requis
			 order by no_requis
			 
			select origen_cheque
			  into _origen_cheque
			  from chqchmae
			 where no_requis = d_requis;
			 
			if _origen_cheque <> '2' then
				continue foreach;
			end if

			if d_debito is null then
				let d_debito = 0; 
			end if
			
			if d_credito is null then
				let d_credito = 0; 
			end if

			let i_neto = d_debito - d_credito ;

			insert into tmp_asiento (
				cuenta,
				comprobante,
				fechatrx,
				notrx,
				debito,
				credito,
				neto,
				origen,
				requis,
				descripcion)
			values (
				'1220103',
				v_comp,
				v_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_requis,
				v_descrip);
		end foreach;

	end if   
end foreach;
END FOREACH

foreach	
  select requis,
         descripcion,
		 sum(debito),
		 sum(credito),
		 sum(neto)
	into d_requis,
	     v_descrip,
		 d_debito,
	     d_credito,
		 i_neto
    from tmp_asiento
	where cuenta      = '1220103'
--	and   comprobante = a_comp
--	and   fechatrx    = a_fecha
	group by requis, descripcion
	order by requis, descripcion
	
	select monto, cod_agente, fecha_anulado, fecha_captura
	  into _monto, _cod_agente, _fecha_anulado, _fecha_genera
	  from chqchmae
	 where no_requis = d_requis;
	 
	select nombre
	  into _agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select desc_cheque[22,31],
           desc_cheque[36,45]
      into _fecha_desde,
           _fecha_hasta
      from chqchdes
     where no_requis = d_requis
       and renglon = 1;	 
	
  let _no_requis = null;
  
  let _dif = 0;
  
  if v_descrip like "%ANULADO%" THEN
	let _dif = i_neto - _monto;
  else
    let _dif = i_neto + _monto;
  end if

  if _dif <> 0 then	
      foreach
		select no_requis
		  into _no_requis
		  from chqcomis
		 where cod_agente = _cod_agente
		   and fecha_desde >= _fecha_desde
		   and fecha_hasta <= _fecha_hasta
		exit foreach;
	  end foreach

	  return d_requis,
	         _fecha_genera,
	         _cod_agente,
	         _agente,
			 v_descrip,
			 _fecha_anulado,
			 d_debito,
			 d_credito,
			 i_neto,
			 _monto,
			 _dif,
             _fecha_desde,
             _fecha_hasta,
             _no_requis			 
			 with resume;
  end if
end foreach;


drop table tmp_asiento;
end procedure					 