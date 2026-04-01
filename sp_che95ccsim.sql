-- Reporte de los Bonificacion de Rentabilidad 2011
-- Creado    : 24/02/2011 - Autor: Henry Giron
-- Modificado: 24/02/2011 - Autor: Henry Giron

DROP PROCEDURE sp_che95ccsim;
CREATE PROCEDURE sp_che95ccsim(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
RETURNING CHAR(50),CHAR(100),CHAR(5),CHAR(50),CHAR(1),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,4),DEC(16,2),CHAR(7),CHAR(1);
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
DEFINE _cod_tipo		 CHAR(3);
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
define _sinis_tmp        dec(16,2);
DEFINE _porcentaje   	 DEC(16,4);
DEFINE _valor_prima   	 DEC(16,2);
DEFINE _Ramo_crec 		 DEC(16,2);
DEFINE _Ramo_Porc_crec 	 DEC(16,2);
DEFINE _porc_prima_dev_max	DEC(16,2);
DEFINE _pri_dev_max_aa		DEC(16,2);
DEFINE _pri_dev_max_ap		DEC(16,2);
DEFINE _prim_suscrita_min 	DEC(16,2);
DEFINE _crecimiento_min   	DEC(16,2);
DEFINE _pri_susc_dev_aa  	DEC(16,2);
DEFINE _pri_susc_dev_ap  	DEC(16,2);
DEFINE a_periodo2           char(7);
DEFINE _estatus				char(1);
DEFINE _estatus_licencia    char(1);


--SET DEBUG FILE TO "che95c.trc";

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
	cod_tipo			CHAR(3),
	cod_agente			CHAR(5),
	prima_ant   		DEC(16,2))
	WITH NO LOG;

CREATE TEMP TABLE chqrenta030212c
	(cia                CHAR(50),	   	 
	periodo             CHAR(7),		 
	no_documento        CHAR(20),		 	
	cod_agente          CHAR(5),		 
	n_agente			CHAR(100),		 
	tipo                CHAR(3),		 
	nombre_ramo			CHAR(50),		 
	pri_sus_pag_ap		DEC(16,2),		 
	pri_sus_pag_aa		DEC(16,2),		 
	n_cliente			CHAR(100),		 
	cod_ramo			CHAR(3),		 
	monto_90_aa			DEC(16,2),		 
	sini_inc			DEC(16,2),		 
	pri_susc_dev_aa  	DEC(16,2),
	pri_susc_dev_ap  	DEC(16,2))
	WITH NO LOG;

let v_nombre_cia    = sp_sis01(a_cia); 
let _crecimiento    = 0;
let _Porc_crec      = 100;
let a_cia           = a_cia        ;
let a_cod_agente	= a_cod_agente ;	
let a_periodo		= a_periodo	   ;	
let _sinis_tmp      = 0;

	insert into chqrenta030212c(
		   cia,             
		   periodo,          
		   no_documento,     
		   cod_agente,       
		   n_agente,			
		   tipo,             		
		   nombre_ramo,			
		   pri_sus_pag_ap,		
		   pri_sus_pag_aa,
		   n_cliente,	
		   cod_ramo,	
		   monto_90_aa,	
		   sini_inc,
		   pri_susc_dev_aa,
		   pri_susc_dev_ap)
	select v_nombre_cia,
	       periodo,
		   trim(no_documento),
	       trim(cod_agente),
	       trim(n_agente),
	       trim(tipo),
		   trim(nombre_ramo),
	       pri_susc_ap,
	       pri_susc_aa,
		   n_cliente,	
		   cod_ramo,	
		   monto_90,	
		   sini_inc,
		   pri_susc_dev_aa,
		   pri_susc_dev_ap
	  from rentabilidad4
	 where periodo  = a_periodo
	   and monto_90 = 0;


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
	       pri_sus_pag_ap,
		   pri_susc_dev_aa,
		   pri_susc_dev_ap
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
		   _prima_ant,
		   _pri_susc_dev_aa,
		   _pri_susc_dev_ap
	 from chqrenta030212c 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
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

			let _reserva = _prima_exc_m90 * _porc_res_mat / 100; --Reserva de PND
 		    let _monto_90 = _prima_ant * _porc_res_mat / 100;	 --Liberacion de reserva de PND

			select porc_res_mat
			  into _porc_res_mat
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if  _porc_res_mat is null or _porc_res_mat = 0 then
				let _porc_res_mat = 100;
			end if
			let _porc_res_mat   = 100 - _porc_res_mat;

			let _prima_aplica = _prima_exc_m90 * _porc_res_mat / 100 + _monto_90;
			let _prima_aplica = _prima_exc_m90 - _reserva + _monto_90;

			let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
			LET _nombre_cliente = trim(_n_cliente);


				select trim(name_tipo)
				  into _nombre_tipo
				  from prdrenttipo 
			     where periodo  = a_periodo
			       and cod_tipo = _cod_tipo 
			       and activo   = 1;

			if  _prima_aplica is null or _prima_aplica = 0 then
				let _prima_aplica = 0;
			end if

		 insert into tmpche95c(cia,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,categoria,ramo,agente,cod_tipo,cod_agente,prima_ant)
		 values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_nombre_tipo,_nombre_ramo,_nombre_agente,_cod_tipo,_cod_agente,_prima_ant);			 

END FOREACH

--CORREDOR	CATEGORIA	PRIMA SUSCRITA	POLIZA CON SALDO A + 90 DIAS	PRIMA SUSCRITA QUE APLICA	RESERVA DE PND	PRIMA SUSCRITA QUE APLICA	SINIESTROS	SINIESTRALIDAD	BENEFICIO	BONO
--TRACE ON;
select agt_per_fidel into a_periodo2 from parparam;
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

		if  _prima_ant is null or _prima_ant <= 0 then
		    if _prima_aa = 0 then
				let _crecimiento = 0;
				let _Porc_crec   = 0;
			else
				let _crecimiento = _prima_aa;
				let _Porc_crec   = 100;
   		    end if
		else
			let _crecimiento = _prima_aa - _prima_ant;
			let _Porc_crec   = (_crecimiento / _prima_ant) * 100;
		end if

		let _porcentaje = 0;

	--************************************************
	--    Calculos % de siniestralidad 2010	
	--************************************************
	let _siniestralidad = 0;
	if _prima_aplica <> 0 then
		let _siniestralidad = (_sini / _prima_aplica) * 100;
	else
		--continue foreach;
	end if		

		select prim_suscrita_min,
		       crecimiento_min,
			   porc_prima_dev_max
		  into _prim_suscrita_min,
			   _crecimiento_min,
			   _porc_prima_dev_max  
		  from prdrenttipo 
	     where periodo  = a_periodo
	       and cod_tipo = _cod_tipo 
	       and activo   = 1 ;

		if _prima_aa >= _prim_suscrita_min then

			if _Porc_crec >= _crecimiento_min then

				let _porcentaje = 0; 
				{if _siniestralidad < 0 then
					let _sinis_tmp = _siniestralidad;
					let _siniestralidad = 0;
				end if	}
				select beneficio 
				  into _porcentaje
				  from prdrenttsin
				 where periodo  = a_periodo
				   and cod_tipo = _cod_tipo
				   and round(_siniestralidad,0) between rango_inicial and rango_final;
				   {if _sinis_tmp < 0 then
					let _siniestralidad = _sinis_tmp;
				   end if	}
				   if _porcentaje is null then
					   let _porcentaje = 0; 
				   end if

			end if		

		end if		


	let _valor_prima = 0;
	if _porcentaje >= 0 then																																		         
		let _valor_prima = _prima_aplica * ( _porcentaje / 100);
		select estatus_licencia into _estatus_licencia from agtagent where cod_agente = _cod_agente;
		let _estatus = "";
		if trim(_estatus_licencia) <> "A" then
			let _estatus = "*";
		end if

		RETURN  v_nombre_cia,
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
				_valor_prima,
				a_periodo2,
				_estatus WITH RESUME;	
	end if
END FOREACH

DROP TABLE tmpche95c;
DROP TABLE chqrenta030212c;

END PROCEDURE;  
