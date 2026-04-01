-- Reporte de los Bonificacion de Rentabilidad 2011
-- Creado    : 24/02/2011 - Autor: Henry Giron
-- Modificado: 24/02/2011 - Autor: Henry Giron

DROP PROCEDURE sp_che95b;
CREATE PROCEDURE sp_che95b(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
RETURNING CHAR(50),CHAR(100),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(50),CHAR(50),CHAR(100);  

DEFINE v_nombre_cia      CHAR(50);
DEFINE _TotProdAnt       DEC(16,2);
DEFINE _TotProdAct       DEC(16,2);
DEFINE _cod_agente       CHAR(5);  
DEFINE _cod_ramo         CHAR(3); 
DEFINE _n_agente         CHAR(50); 
DEFINE _nombre_agente    CHAR(100); 
DEFINE _nombre_cliente   CHAR(100); 
DEFINE _cod_tipo		 CHAR(1);
DEFINE _nombre_tipo      CHAR(50);
DEFINE _nombre_ramo      CHAR(50);
DEFINE _ProdAntRam       DEC(16,2);
DEFINE _ProdActRam       DEC(16,2);
DEFINE _ProducMin        DEC(16,2);
DEFINE _crecimiento		 DEC(16,2);
DEFINE _Porc_crec    	 DEC(16,2);
DEFINE _n_cliente 	     CHAR(100); 
DEFINE _no_documento     CHAR(20); 
DEFINE _prima_aa    	 DEC(16,2);
DEFINE _monto_90    	 DEC(16,2);
DEFINE _sini	    	 DEC(16,2);
DEFINE _prima_exc_m90    DEC(16,2);
DEFINE _reserva	    	 DEC(16,2);
DEFINE _porc_res_mat   	 DEC(16,2);
DEFINE _prima_aplica   	 DEC(16,2);

--SET DEBUG FILE TO "che95b.trc";
--TRACE ON;
--DROP TABLE tmpche95b ;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmpche95b
	(cia                CHAR(50),
	asegurado			CHAR(100),
	poliza				CHAR(20),
	prima_suscrita		DEC(16,2),
	monto_90			DEC(16,2),
	prima_exc_monto90	DEC(16,2),
	reserva				DEC(16,2),
	prima_exc_reserva	DEC(16,2),
	siniestro			DEC(16,2),
	categoria			CHAR(50),
	ramo				CHAR(50),	
	agente				CHAR(100))
	WITH NO LOG;

let v_nombre_cia = sp_sis01(a_cia); 
let _crecimiento = 0;
let _Porc_crec   = 100;

FOREACH
	select trim(cod_agente),
	       trim(n_agente),
	       tipo,	
	       trim(n_cliente),
		   trim(cod_ramo),
		   nombre_ramo,
	       trim(no_documento),
	       pri_sus_pag_aa,
	       monto_90_aa,
		   sini_inc
	  into _cod_agente,
	       _n_agente,
	       _cod_tipo,
		   _n_cliente,
		   _cod_ramo,
		   _nombre_ramo,
		   _no_documento,
		   _prima_aa,  
		   _monto_90,
		   _sini
	 from chqrenta 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
--	  and tipo = 'C' 
--	  and (pri_sus_pag_aa <> 0 or (pri_sus_pag_aa = 0 and sini_inc <> 0))
--	  and (pri_sus_pag_aa <> 0 and pri_sus_pag_ap <> 0 and sini_inc <> 0)
	order by 1,2,3,4,5,6,7,8 desc

  
			if  _prima_aa is null or _prima_aa = 0 then
				let _prima_aa = 0;
			end if
			let _prima_exc_m90 = _prima_aa;

			if  _monto_90 is null or _monto_90 = 0 then
				let _monto_90 = 0;
			else
				let _prima_exc_m90 = 0;
			end if
			if  _sini is null or _sini = 0 then
				let _sini = 0;
			end if

			if  _prima_aa = 0 and _monto_90 = 0 and _sini = 0 then
				continue foreach;
			end if

			select porc_res_mat
			  into _porc_res_mat
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if  _porc_res_mat is null or _porc_res_mat = 0 then
				let _porc_res_mat = 100;
			end if

			let _reserva = _prima_exc_m90 * _porc_res_mat / 100;

			let _porc_res_mat   = 100 - _porc_res_mat;

			if  _porc_res_mat is null or _porc_res_mat = 0 then
				let _porc_res_mat = 100;
			end if

			let _prima_aplica = _prima_exc_m90 * _porc_res_mat / 100;

			if  _prima_aplica is null or _prima_aplica = 0 then
				let _prima_aplica = 0;
			end if

			let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
			LET _nombre_cliente = trim(_n_cliente);

			if  _cod_tipo = 'A' then 
			    let _nombre_tipo = 'AUTOMOVIL'  ;
	        end if
			if  _cod_tipo = 'B' then 
			    let _nombre_tipo = 'SALUD'  ;
	        end if
			if  _cod_tipo = 'C' then 
			    let _nombre_tipo = 'PATRIMONIAL'  ;
	        end if
			if  _cod_tipo = 'D' then 
			    let _nombre_tipo = 'PERSONAS'  ;
	        end if
			if  _cod_tipo = 'E' then 
			    let _nombre_tipo = 'FIANZAS'  ;
	        end if

		 insert into tmpche95b(cia,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,categoria,ramo,agente)
		 values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_nombre_tipo,_nombre_ramo,_nombre_agente);			 

END FOREACH


FOREACH
	select cia,agente,categoria,ramo,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro
	  into v_nombre_cia,_nombre_agente,_nombre_tipo,_nombre_ramo,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini
	  from tmpche95b 
	 order by 1,2,3,4,5,6,7 desc


	RETURN v_nombre_cia,
			_nombre_cliente,
			_no_documento,
			_prima_aa,
			_monto_90,
			_prima_exc_m90,
			_reserva,
			_prima_aplica,
			_sini,
			_nombre_tipo,
			_nombre_ramo,
			_nombre_agente WITH RESUME;	
	
END FOREACH

DROP TABLE tmpche95b ;

END PROCEDURE;  
