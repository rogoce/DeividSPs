--***********************************************************************************
-- Procedimiento que genera la Bonificacion de Rentabilidad por corredores
--***********************************************************************************
-- Este es el procedimiento real NEGOCIO 2011 - Realizado: 23/01/2012 Henry Giron	 
-- execute procedure sp_che94("001","001","2011-12","HGIRON")
-- Creado    : 28/01/2009 - Autor: Henry Giron
-- Ultima Modificacion: 23/01/2012 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_che94;

CREATE PROCEDURE sp_che94(
a_cia               CHAR(3),
a_sucursal          CHAR(3),
v_periodo_aa        CHAR(7),  
a_usuario           CHAR(8)
) RETURNING SMALLINT,CHAR(50),CHAR(3);

--DROP PROCEDURE sp_che95c;
--CREATE PROCEDURE sp_che95c(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
--RETURNING CHAR(50),CHAR(100),CHAR(5),CHAR(50),CHAR(1),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

DEFINE v_nombre_cia      	CHAR(50);
DEFINE _TotProdAnt       	DEC(16,2);
DEFINE _TotProdAct       	DEC(16,2);
DEFINE _cod_agente       	CHAR(5);  
DEFINE _cod_ramo         	CHAR(3); 
DEFINE _n_agente         	CHAR(50); 
DEFINE _nombre_agente    	CHAR(100); 
DEFINE _nombre_cliente   	CHAR(100); 
DEFINE _cod_tipo		 	CHAR(3);
DEFINE _nombre_tipo      	CHAR(50);
DEFINE _nombre_ramo      	CHAR(50);
DEFINE _ProdAntRam       	DEC(16,2);
DEFINE _ProdActRam       	DEC(16,2);
DEFINE _ProducMin        	DEC(16,2);
DEFINE _crecimiento		 	DEC(16,2);
DEFINE _Porc_crec    	 	DEC(16,2);
DEFINE _n_cliente 	     	CHAR(100); 
DEFINE _no_documento     	CHAR(20); 
DEFINE _prima_aa    	 	DEC(16,2);
DEFINE _monto_90    	 	DEC(16,2);
DEFINE _liberacion_ap  	 	DEC(16,2);
DEFINE _sini	    	 	DEC(16,2);
DEFINE _prima_exc_m90    	DEC(16,2);
DEFINE _reserva	    	 	DEC(16,2);
DEFINE _porc_res_mat   	 	DEC(16,2);
DEFINE _prima_aplica   	 	DEC(16,2);
DEFINE _prima_ant   	 	DEC(16,2);
DEFINE _siniestralidad 	 	DEC(16,2);
DEFINE _porcentaje   	 	DEC(16,2);
DEFINE _valor_prima   	 	DEC(16,2);
DEFINE _Ramo_crec 		 	DEC(16,2);
DEFINE _Ramo_Porc_crec 	 	DEC(16,2);
DEFINE _porc_prima_dev_max	DEC(16,2);
DEFINE _pri_dev_max_aa		DEC(16,2);
DEFINE _pri_dev_max_ap		DEC(16,2);
DEFINE _prim_suscrita_min 	DEC(16,2);
DEFINE _crecimiento_min   	DEC(16,2);
DEFINE _pri_susc_dev_aa  	DEC(16,2);
DEFINE _pri_susc_dev_ap  	DEC(16,2); 
DEFINE _cod_contratante		CHAR(10); 
DEFINE _no_poliza		    CHAR(10); 
DEFINE _vigenteaa           DATE; 
DEFINE _vigenteap           DATE; 

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
	cod_tipo			CHAR(3),
	cod_agente			CHAR(5),
	prima_ant   		DEC(16,2),
	liberacion_ap       DEC(16,2))
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
let _liberacion_ap  = 0;

FOREACH
	select trim(cod_agente),
	       trim(n_agente),
	       tipo,
	       trim(n_cliente),
		   trim(cod_ramo),
		   nombre_ramo,
	       trim(no_documento),
	       pri_susc_aa,
	       monto_90,
		   sini_inc,
	       pri_susc_ap,
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
	  from rentabilidad1 
	 where periodo = a_periodo 
	   and tipo is not null and cod_agente in ('01068','01653','01654','01655','01656','01657','01658','01659','01660','01661','01662','01663','01664','01807','01839','02041')
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

			let _liberacion_ap = 0; 
			let _reserva = _prima_exc_m90 * _porc_res_mat / 100 ;
			let _liberacion_ap = _prima_ant * _porc_res_mat / 100; 

			select porc_res_mat
			  into _porc_res_mat
			  from prdramo
			 where cod_ramo = _cod_ramo;

			if  _porc_res_mat is null or _porc_res_mat = 0 then
				let _porc_res_mat = 100;
			end if
			let _porc_res_mat   = 100 - _porc_res_mat;

			let _prima_aplica = _prima_exc_m90 - _reserva + _liberacion_ap ;

			let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
			let _nombre_cliente = trim(_n_cliente);

			select trim(name_tipo)
			  into _nombre_tipo
			  from prdrenttipo 
		     where periodo  = a_periodo
		       and cod_tipo = _cod_tipo 
		       and activo   = 1 ;					

			if  _prima_aplica is null or _prima_aplica = 0 then
				let _prima_aplica = 0;
			end if

		 insert into tmpche95c(cia,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,categoria,ramo,agente,cod_tipo,cod_agente,prima_ant,liberacion_ap)
		 values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_nombre_tipo,_nombre_ramo,_nombre_agente,_cod_tipo,_cod_agente,_prima_ant,_liberacion_ap);			 

	        let _no_poliza = sp_sis21(_no_documento);

		 select cod_contratante,
		        vigencia_final,
				vigencia_inic,
				cod_ramo
		   into _cod_contratante,
				_vigenteaa,
				_vigenteap,
				_cod_ramo
		   from emipomae
		  where no_poliza = _no_poliza;

		insert into chqrenta(
		cod_agente, 
		no_documento, 
		pri_sus_pag_aa, 
		pri_sus_pag_ap, 
		sini_inc, 
		n_agente, 
		vigenteaa,
		vigenteap, 
		cod_contratante, 
		n_cliente,
		periodo,
		renovaa,
		renovap,
		pri_pag_aa,
		pri_can_aa,
		pri_dev_aa,
		monto_90_aa,
		pri_pag_ap,
		pri_can_ap,
		pri_dev_ap,
		monto_90_ap,
		cod_vendedor,
		nombre_vendedor,
		cod_ramo,
		nombre_ramo,
		tipo_agente,
		tipo,
		pri_sus_dev,
		reserva,
		liberacion
		)
		values(
		_cod_agente, 
		_no_documento, 
		_prima_aa, 
		_prima_ant, 
		_sini, 
		_nombre_agente, 
 		_vigenteaa,
		_vigenteap,
		_cod_contratante, 
		_nombre_cliente,
		a_periodo,
		0,
		0,
		0,
		0,
		_pri_susc_dev_aa,
		_monto_90,
		0,
		0,
		_pri_susc_dev_ap,
		0,
		_cod_vendedor,
		_nombre_vendedor,
		_cod_ramo,
		_nombre_ramo,
		_nombre_tipo,
		_cod_tipo,
	    _pri_susc_dev_aa,
		_reserva,
		_liberacion_ap
		);

END FOREACH

--CORREDOR	CATEGORIA	PRIMA SUSCRITA	POLIZA CON SALDO A + 90 DIAS	PRIMA SUSCRITA QUE APLICA	RESERVA DE PND	PRIMA SUSCRITA QUE APLICA	SINIESTROS	SINIESTRALIDAD	BENEFICIO	BONO

FOREACH
	select cia,agente,cod_agente,categoria,cod_tipo,sum(prima_suscrita),sum(monto_90),sum(prima_exc_monto90),sum(reserva),sum(prima_exc_reserva),sum(siniestro),sum(prima_ant),sum(liberacion_ap)
	  into v_nombre_cia,_nombre_agente,_cod_agente,_nombre_tipo,_cod_tipo,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_prima_ant,_liberacion_ap
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

			select beneficio 
			  into _porcentaje
			  from prdrenttsin
			 where periodo  = a_periodo
			   and cod_tipo = _cod_tipo
			   and round(_siniestralidad,0) between rango_inicial and rango_final;

				if _porcentaje is null then
				   let _porcentaje = 0; 
			   end if

		end if		

	end if		

	let _valor_prima = 0;																																		         
	if _porcentaje <> 0 then	
		let _valor_prima = _prima_aplica * ( _porcentaje / 100);

		update rentabilidad1
		   set bono = _valor_prima,
		       beneficio = _porcentaje,
			   aplica    = 1
		 where cod_agente =	_cod_agente
		   and tipo		  =	_cod_tipo
		   and periodo    = "2011-12";


		INSERT INTO chqrenta3(cod_agente,prima_neta,comision,nombre,seleccionado,periodo,fecha_genera,cod_ramo,
						cod_subramo,cod_origen,nombre_cte,por_persistencia,porcentaje,por_cre,por_sin,prima_ap,nombre_ramo,
						nombre_tipo_g,tipo_g,prima_neta_g,comision_g,porcentaje_g,por_cre_g,por_sin_g,prima_ap_g,sini_g,sini )
		VALUES (_cod_agente,_prima_aplica,_valor_prima,_nombre_agente,0,a_periodo,current,_cod_ramo,
			  _cod_subramo,_cod_origen,v_nombre_clte,_valor,_porcentaje,_crecimiento,_siniestralidad,_pri_sus_pag_ap, _nombre_ramo,
			  _nombre_tipo_g,_tipo_g,_prima_neta_g,_comision_g,_porcentaje_g,_por_cre_g,_por_sin_g,_prima_ap_g,_sini_g,_sini_i  );

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
DROP TABLE chqrenta030212c ;

END PROCEDURE;  
