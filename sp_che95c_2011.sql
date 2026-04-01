-- Reporte de los Bonificacion de Rentabilidad 2011
-- Creado    : 24/02/2011 - Autor: Henry Giron
-- Modificado: 24/02/2011 - Autor: Henry Giron

DROP PROCEDURE sp_che95c;
CREATE PROCEDURE sp_che95c(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
RETURNING CHAR(50),CHAR(100),CHAR(5),CHAR(50),CHAR(1),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);
 -- v_nombre_cia,
 -- nombre_agente,
 -- cod_agente,
 -- nombre_tipo,
 -- cod_tipo,
 -- prima_aa,
 -- monto_90,
 -- prima_exc_m90,
 -- reserva,
 -- prima_aplica,
 -- sini,
 -- prima_ant,
 -- crecimiento,
 -- Porc_crec,
 -- siniestralidad 
 -- Porcentaje
 -- Bono

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
DEFINE _prima_ant   	 DEC(16,2);
DEFINE _siniestralidad 	 DEC(16,2);
DEFINE _porcentaje   	 DEC(16,2);
DEFINE _valor_prima   	 DEC(16,2);
DEFINE _Ramo_crec 		 DEC(16,2);
DEFINE _Ramo_Porc_crec 	 DEC(16,2);



--SET DEBUG FILE TO "che95c.trc";
--TRACE ON;
--DROP TABLE tmpche95c ;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmpche95c
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
	agente				CHAR(100),
	cod_tipo			CHAR(1),
	cod_agente			CHAR(5),
	prima_ant   		DEC(16,2))
	WITH NO LOG;

let v_nombre_cia    = sp_sis01(a_cia); 
let _crecimiento    = 0;
let _Porc_crec      = 100;

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
		   sini_inc,
	       pri_sus_pag_ap
	  into _cod_agente,
	       _n_agente,
	       _cod_tipo,
		   _n_cliente,
		   _cod_ramo,
		   _nombre_ramo,
		   _no_documento,
		   _prima_aa,  
		   _monto_90,
		   _sini,
		   _prima_ant
	 from chqrenta 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
--	  and tipo = 'C' 
--	  and (pri_sus_pag_aa <> 0 ) or (pri_sus_pag_aa = 0 and sini_inc <> 0) or (pri_sus_pag_aa = 0 and pri_sus_pag_ap <> 0 ))
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
			if  _cod_tipo = 'C' then 
			    let _nombre_tipo = 'PATRIMONIAL'  ;
	        end if
			if  _cod_tipo = 'D' then 
			    let _nombre_tipo = 'PERSONAS'  ;																											
	        end if																																			

		 insert into tmpche95c(cia,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,categoria,ramo,agente,cod_tipo,cod_agente,prima_ant)
		 values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_nombre_tipo,_nombre_ramo,_nombre_agente,_cod_tipo,_cod_agente,_prima_ant);			 

END FOREACH

--CORREDOR	CATEGORIA	PRIMA SUSCRITA	POLIZA CON SALDO A + 90 DIAS	PRIMA SUSCRITA QUE APLICA	RESERVA DE PND	PRIMA SUSCRITA QUE APLICA	SINIESTROS	SINIESTRALIDAD	BENEFICIO	BONO

FOREACH
	select cia,agente,cod_agente,categoria,cod_tipo,sum(prima_suscrita),sum(monto_90),sum(prima_exc_monto90),sum(reserva),sum(prima_exc_reserva),sum(siniestro),sum(prima_ant)
	  into v_nombre_cia,_nombre_agente,_cod_agente,_nombre_tipo,_cod_tipo,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_prima_ant
	  from tmpche95c 
	 group by 1,2,3,4,5
	 order by 1,2,3,4,5,6 desc

		let _crecimiento    = 0;
		let _Porc_crec      = 0;
		let _Ramo_crec 		= 0;
		let _Ramo_Porc_crec = 0; 

		if  _prima_ant is null or _prima_ant = 0 then
			let _crecimiento = _prima_aa;
			let _Porc_crec   = 100;
		else
			let _crecimiento = _prima_aa - _prima_ant ;
			let _Porc_crec   = (_crecimiento / _prima_ant) * 100;
		end if

		let _porcentaje   = 0;
	--************************************************
	--    Calculos % de siniestralidad 2010	
	--************************************************
	let _siniestralidad = 0;
	if _prima_aplica <> 0 then
		let _siniestralidad = (_sini / _prima_aplica) * 100;
	else
		continue foreach;
	end if		

--************************************************
	--   Condicionar aud_renta
	--************************************************
	if _cod_tipo = 'A' then	  --   automovil
		if _prima_aa >= 25000 then 
			if _Porc_crec >= 25 then						
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 
	
	if _cod_tipo = 'C' then     -- patrimoniales
		if _prima_aa >= 15000 then 
			if _Porc_crec >= 25 then						
				if _siniestralidad <= 30 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 30 and _siniestralidad <= 40 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 40 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 					

	if _cod_tipo = 'D' then	  --   Personas
		if _prima_aa >= 15000 then 
			if _Porc_crec >= 25 then	
				if _siniestralidad <= 40 then
					let _porcentaje = 5;
				end if	 
				if _siniestralidad > 40 and _siniestralidad <= 45 then
					let _porcentaje = 4;
				end if
				if _siniestralidad > 45 and _siniestralidad <= 50 then
					let _porcentaje = 3;
				end if
			end if					
		end if
	end if 	  

	let _valor_prima = 0;																																		         
	if _porcentaje <> 0 then	
	let _valor_prima = _prima_aplica * ( _porcentaje / 100);


	RETURN v_nombre_cia,
			_nombre_agente,
			_cod_agente,
			_nombre_tipo,
			_cod_tipo,
			_prima_aa,
			_monto_90,
			_prima_exc_m90,
			_reserva,
			_prima_aplica,
			_sini,
			_prima_ant,
			_crecimiento,
			_Porc_crec/100,
			_siniestralidad/100,
			_porcentaje/100,
			_valor_prima WITH RESUME;	
	end if
	
END FOREACH

DROP TABLE tmpche95c ;

END PROCEDURE;  


