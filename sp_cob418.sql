-- Procedimiento que carga los pagos diarios de un corredor Ducruet
-- Creado    : 20/09/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- Execute procedure sp_cob418('001','001','2018-01','02618','1122')

DROP PROCEDURE sp_cob418;
CREATE PROCEDURE sp_cob418(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7), a_cod_agente CHAR(5) default "*", a_cod_grupo CHAR(5) default "*")
returning CHAR(5) as 	cod_agente,
		CHAR(50) as 	nombre_agente,
		CHAR(10) as 	no_poliza,
		CHAR(10) as 	no_recibo,
		DATE     as	fecha,
		CHAR(20) as 	no_documento,
		CHAR(100) as 	nombre_clte,
		CHAR(50) as 	nom_grupo,
		CHAR(5) as 	cod_grupo,		
		DATE as	vigencia_inic,
		DATE as	vigencia_final,
		CHAR(50) as 	estatus_desc,
		DEC(16,2) as 	prima_susc,
		SMALLINT as	no_pagos,
		DATE as	fecha_1er_pago,		
		DEC(16,2) as 	prima_neta,
		DEC(5,2) as 	porc_partic,
		DEC(5,2) as 	porc_comis,
		DEC(5,2) as 	porc_banisi,		
		DEC(5,2) as 	porc_web,
		DEC(16,4) as 	monto_banisi,		
		DEC(16,4) as 	monto_web,		
		DEC(16,4) as 	comision,
		CHAR(50) as _nombre_compania,
		DATE as fecha_desde,
 	    DATE as fecha_hasta,
		DEC(5,2) as 	porc_agente,
		DEC(16,4) as 	monto_agente,
		DATE as fecha_ult_pp,
		DEC(16,2) as porc_pronto_pago,
		DEC(16,4) as monto_pronto_pago,
		SMALLINT as	dif_pago;
			
DEFINE _nombre_compania	    CHAR(50);
DEFINE _cod_agente          CHAR(5);  
DEFINE _no_poliza           CHAR(10); 
DEFINE _nombre              CHAR(50); 
DEFINE _no_documento        CHAR(20); 
DEFINE _estatus_poliza      CHAR(1);
DEFINE _nombre_clte         CHAR(100); 
DEFINE _cod_cliente         CHAR(10);
DEFINE _nombre_agente       CHAR(50); 
DEFINE _no_recibo           CHAR(10); 
DEFINE _cod_grupo  		    CHAR(5); 
define _estatus_desc        CHAR(50);
define _nom_grupo           CHAR(50);
define _vigencia_final 		DATE;
define _vigencia_inic 		DATE;
DEFINE _fecha               DATE;     
DEFINE _fecha_desde 	    DATE;
DEFINE _fecha_hasta 	    DATE;
DEFINE _porc_partic         DEC(5,2); 
DEFINE _porc_comis          DEC(5,2); 
DEFINE _comision            DEC(16,4);
DEFINE _sobrecomision       DEC(16,2);
DEFINE _porc_banisi         DEC(16,2);
DEFINE _monto_banisi        DEC(16,4);
DEFINE _porc_web            DEC(16,2);
DEFINE _monto_web           DEC(16,4);
DEFINE _porc_agente         DEC(16,2);
DEFINE _monto_agente        DEC(16,4);
define _prima_suscrita      DEC(16,2);
define _prima_neta_cobrada  DEC(16,2); 
define _fecha_1er_pago      DEC(16,2); 	
define _no_pagos            SMALLINT;
define _cnt_dias            INTEGER;
define _fecha_suscripcion	DATE;
define _periodo_real        char(7);
define _fecha_ult_dia		date;
define _fecha_comparar		date;
define _fecha_conviene		date;
define _cod_ramo		    char(3);
DEFINE _porc_pronto_pago    DEC(16,2);
DEFINE _monto_pronto_pago   DEC(16,4);
define _dif_pago            SMALLINT;


define _tot_id,_tot_monto_banisi,_tot_monto_web,_tot_monto_agente,_tot_comision,_tot_dif,_tot_monto_prt_pago  dec(16,2);


--set debug file to "sp_cob418.trc";
--trace on;
drop table if exists temp_banisi;	
CREATE TEMP TABLE temp_banisi(	
cod_agente		  CHAR(5),            
nombre_agente     CHAR(50),
no_poliza		  CHAR(10),	         
no_recibo		  CHAR(10),	         
fecha			  DATE, 
no_documento      CHAR(20), 
nombre_clte    	  CHAR(100), 
nom_grupo         CHAR(50),
cod_grupo  		  CHAR(5),
vigencia_inic     DATE, 
vigencia_final    DATE, 
estatus_desc      CHAR(50),
prima_susc        DEC(16,2), 
no_pagos          SMALLINT,
fecha_1er_pago    DATE, 
prima_neta        DEC(16,2),
porc_partic		  DEC(5,2),	         
porc_comis		  DEC(5,2),	
porc_banisi       DEC(5,2),	
porc_pronto_pago  DEC(5,2),	
porc_web          DEC(5,2),	
porc_agente       DEC(5,2),	
monto_banisi      DEC(16,4),
monto_pronto_pago DEC(16,2),
monto_web         DEC(16,4),
monto_agente      DEC(16,4),
comision          DEC(16,4),
fecha_ult_pp      DATE,
dif_pago          Smallint,
PRIMARY KEY		(cod_agente, no_documento )
) WITH NO LOG;
	
let _fecha_desde = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);
let _nombre_compania = sp_sis01(a_compania);
let _porc_banisi = 5;      -- Porcentaje de Manejo - Banco BANISI 5% en 1 REN 5.75% 2 REN 6.50%, siniestralidad < 55%
let _porc_web = 0;         -- Porcentaje Web 1%
let _porc_agente = 0;      -- Porcentaje de Manejo - Corredor 1%
LET _porc_pronto_pago = 0;  -- Porcentaje de Pronto Pago 3 en caso de cumplir condicion
LET _monto_pronto_pago  = 0;
Let _dif_pago = 0;
LET _comision = 0;
let _monto_web = 0;

FOREACH
select e.no_poliza, count(*), max(c.fecha), sum(c.prima_neta)
  into _no_poliza, _no_pagos, _fecha, _prima_neta_cobrada
  from cobredet c, emipomae e, cobreagt a
 where c.no_poliza = e.no_poliza
   and c.no_remesa = a.no_remesa
   and c.renglon = a.renglon
   and c.tipo_mov    IN ('P','N')
   and c.actualizado = 1
   and e.actualizado = 1
   and c.periodo = a_periodo
   and (e.cod_grupo matches a_cod_grupo   -- in ('124','125') 
   and a.cod_agente matches a_cod_agente) -- '02531' )   
 group by 1
 order by 1


	FOREACH
	select a.cod_agente,
		   e.no_documento,
		   c.no_recibo,
		   e.cod_contratante,
		   e.cod_grupo,		   
		   e.fecha_suscripcion,
		   e.vigencia_inic,
		   e.vigencia_final,
		   e.estatus_poliza,
		   e.prima_suscrita,		   
		   a.porc_partic_agt, 
		   a.porc_comis_agt,
		   e.fecha_primer_pago,
           e.cod_ramo		   
	  into _cod_agente,
		   _no_documento,
		   _no_recibo,
		   _cod_cliente,
		   _cod_grupo,		   
		   _fecha_suscripcion,
		   _vigencia_inic,
		   _vigencia_final,	   
		   _estatus_poliza,
		   _prima_suscrita,		   
		   _porc_partic,
		   _porc_comis,
		   _fecha_1er_pago,
		   _cod_ramo
	  from cobredet c, emipomae e, cobreagt a
	 where c.no_poliza = e.no_poliza   
	   and c.no_remesa = a.no_remesa   
	   and c.renglon = a.renglon
	   and c.tipo_mov IN ('P','N')   
	   and c.actualizado = 1
	   and e.actualizado = 1   
	   and c.periodo = a_periodo
	   and e.no_poliza = _no_poliza
	   and c.fecha = _fecha
	   and (e.cod_grupo matches a_cod_grupo   -- in ('124','125') 
	   and a.cod_agente matches a_cod_agente) -- '02531' )     	   
	   EXIT FOREACH;	   
	   	END FOREACH				
			
		if _estatus_poliza = 1 then
			LET _estatus_desc = "VIGENTE";
		elif _estatus_poliza = 2 then
			LET _estatus_desc = "CANCELADA";
		elif _estatus_poliza = 3 then
			LET _estatus_desc = "VENCIDA";
		elif _estatus_poliza = 4 then
			LET _estatus_desc = "ANULADA";
		end if
		LET _monto_agente = 0;
		LET _porc_pronto_pago = 0;  -- Porcentaje de Pronto Pago 3 en caso de cumplir condicion		
		LET _monto_pronto_pago  = 0;		
		--let _estatus_desc = _estatus_poliza||" - "||_estatus_desc;
		
		select trim(nombre)
		  into _nom_grupo
		  from cligrupo
		 where cod_grupo = _cod_grupo;			
		 
		select trim(nombre)
		  into _nombre_clte
		  from cliclien
		 where cod_cliente = _cod_cliente;		 				 		 
		 
		select trim(nombre)
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;			 
		 
		if _fecha_suscripcion > _vigencia_inic then   -- SOLICITUD ASTANZIO correo 27/03/2018			
			LET _fecha_conviene = _fecha_suscripcion;						
		else			
			LET _fecha_conviene = _vigencia_inic;
		end if 
		call sp_sis39(_fecha_conviene) returning _periodo_real;
		call sp_sis36(_periodo_real) returning _fecha_ult_dia;
		LET _fecha_comparar = _fecha_ult_dia + 25 units day; -- en lugar de 15 dias seran 20 dias B.B. y 5 dias  U.D.
		LET _monto_banisi = 0;							
		let _dif_pago = _fecha - _fecha_comparar;
		
		if _fecha <= _fecha_comparar then	   
	       if _prima_neta_cobrada >= _prima_suscrita then		  -- Siempre y cuando haiga cubierto prima suscrita 		        
		        LET _monto_banisi = _prima_neta_cobrada * (_porc_banisi / 100);				
				let _porc_pronto_pago = 3; 					
				LET _monto_agente = round((_prima_neta_cobrada * (_porc_agente / 100)),4); 
				LET _monto_pronto_pago  = round(((_prima_neta_cobrada - _monto_banisi - _monto_agente ) * (_porc_pronto_pago / 100)),4); 				
			   if _porc_comis = 0 then   --Roman me indica que por ser corredor directo la comision esta en cero, tomarlo de prdramo si es cero
					select porc_comision
					  into _porc_comis
					  from prdramo
					 where cod_ramo = _cod_ramo;		   
			   end if				
			   
				LET _porc_web = 1;  
				LET _monto_web          = (_prima_neta_cobrada - _monto_banisi - _monto_agente ) * (_porc_web / 100);							 	
				LET _comision           = (_prima_neta_cobrada - _monto_banisi - _monto_agente ) * (_porc_comis / 100);	 			   
				
		   end if
	   end if		 		 		 	 				
	   


			 
		 
		BEGIN 
			ON EXCEPTION IN(-239,-268) 
			END EXCEPTION 
   
			INSERT INTO temp_banisi(
			cod_agente,
			nombre_agente,
			no_poliza,
			no_recibo,
			fecha,
			no_documento,
			nombre_clte,
			nom_grupo,
			cod_grupo,			
			vigencia_inic,
			vigencia_final,
			estatus_desc,
			prima_susc,
			no_pagos,
			fecha_1er_pago, 			
			prima_neta,
			porc_partic,
			porc_comis,
			porc_banisi,			
			porc_web,
			monto_banisi,			
			monto_web,
			porc_agente,
			monto_agente, 			
			comision,
			fecha_ult_pp,
            porc_pronto_pago,
			monto_pronto_pago,
			dif_pago
			)
			VALUES(
			_cod_agente,
			_nombre_agente,
			_no_poliza,
			_no_recibo,
			_fecha,
			_no_documento,
			_nombre_clte,
			_nom_grupo,
			_cod_grupo,			
			_vigencia_inic,
			_vigencia_final,				
			_estatus_desc,
			_prima_suscrita,
			_no_pagos,
			_fecha_1er_pago,			
			_prima_neta_cobrada,
			_porc_partic,
			_porc_comis,
			_porc_banisi,			
			_porc_web,
			_monto_banisi,			
			_monto_web,
			_porc_agente,
			_monto_agente,											
			_comision,
			_fecha_comparar,
			_porc_pronto_pago,
			_monto_pronto_pago,
			_dif_pago
			);										
				
		END	  


END FOREACH
--trace on;
    select sum(-1),
		   sum(round(monto_banisi*-1,3)),
		   sum(round(monto_web*-1,3)),
		   sum(round(monto_agente*-1,3)),
		   sum(round(comision*-1,3)),
		   sum(round(monto_pronto_pago*-1,3))
    into _tot_id, _tot_monto_banisi, _tot_monto_web, _tot_monto_agente, _tot_comision, _tot_monto_prt_pago
    from temp_banisi ;

        let _tot_monto_banisi = round(_tot_monto_banisi,2);
        let _tot_monto_web = round(_tot_monto_web,2);
        let _tot_monto_agente = round(_tot_monto_agente,2);
        let _tot_comision = round(_tot_comision,2);
		let _tot_monto_prt_pago = round(_tot_monto_prt_pago,2);

-- foreach de tmp_banisi
foreach
 select cod_agente,
				nombre_agente,
				no_poliza,
				no_recibo,
				fecha,
				no_documento,
				nombre_clte,
				nom_grupo,
				cod_grupo,				
				vigencia_inic,
				vigencia_final,
				estatus_desc,
				prima_susc,
				no_pagos,
				fecha_1er_pago, 				
				prima_neta,
			    porc_partic,
			    porc_comis,
				porc_banisi, 
				porc_web,
				trunc(monto_banisi,2), 
				trunc(monto_web,2),
				porc_agente,
				trunc(monto_agente,2), 
				trunc(comision,2),
				fecha_ult_pp,
				porc_pronto_pago,
			    trunc(monto_pronto_pago,2),
				dif_pago
   into	_cod_agente,
				_nombre_agente,
				_no_poliza,
				_no_recibo,
		      	_fecha,
				_no_documento,
				_nombre_clte,
				_nom_grupo,
				_cod_grupo,				
				_vigencia_inic,
				_vigencia_final,				
				_estatus_desc,
				_prima_suscrita,
				_no_pagos,
				_fecha_1er_pago,				
				_prima_neta_cobrada,
				_porc_partic,
				_porc_comis,
				_porc_banisi,				
				_porc_web,
				_monto_banisi,				
				_monto_web,
				_porc_agente,
				_monto_agente,									
				_comision,
				_fecha_comparar,
				_porc_pronto_pago,
                _monto_pronto_pago,
                _dif_pago				
   from temp_banisi	
   
		let _tot_id = _tot_id + 1;
        let _tot_monto_banisi = _tot_monto_banisi + _monto_banisi;
        let _tot_monto_web = _tot_monto_web + _monto_web; 
        let _tot_monto_agente = _tot_monto_agente + _monto_agente;
        let _tot_comision = _tot_comision + _comision;
		let _tot_monto_prt_pago = _tot_monto_prt_pago + _monto_pronto_pago ;
		
		if _tot_id = 0 then
			let _monto_banisi = _tot_monto_banisi*-1 + _monto_banisi;
			let _monto_web = _tot_monto_web*-1 + _monto_web; 
			let _monto_agente = _tot_monto_agente*-1 + _monto_agente;
			let _comision = _tot_comision*-1 + _comision;		
			let _monto_pronto_pago = _tot_monto_prt_pago *-1 + _monto_pronto_pago;
		end if

  return _cod_agente,
				_nombre_agente,
				_no_poliza,
				_no_recibo,
		      	_fecha,
				_no_documento,
				_nombre_clte,
				_nom_grupo,
				_cod_grupo,				
				_vigencia_inic,
				_vigencia_final,				
				_estatus_desc,
				_prima_suscrita,
				_no_pagos,
				_fecha_1er_pago,				
				_prima_neta_cobrada,
				_porc_partic,
				_porc_comis,
				_porc_banisi,				
				_porc_web,
				_monto_banisi,				
				_monto_web,				
				_comision,
				_nombre_compania,
				_fecha_desde,
				_fecha_hasta,
				_porc_agente,
				_monto_agente,
                _fecha_comparar,
				_porc_pronto_pago,
                _monto_pronto_pago,
                _dif_pago				
     with resume;
	 
   end foreach	
   
--drop table temp_banisi;

END PROCEDURE;