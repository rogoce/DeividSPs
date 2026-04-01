-- Reporte de los Bonificacion de Rentabilidad 2011  - detalle de polizas
-- Creado    : 24/02/2011 - Autor: Henry Giron 
-- Modificado: 09/03/2017 - Autor: Henry Giron 
-- execute procedure sp_che220_d("001","*","2016-12")  

DROP PROCEDURE sp_che220_d; 
CREATE PROCEDURE sp_che220_d(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7)) 
RETURNING 
				CHAR(50),   -- nombre_cia
				CHAR(100),  -- nombre_agente
				CHAR(5),    -- cod_agente
				DEC(16,2),  -- prima_aa 
				DEC(16,2),  -- sini 
				DEC(16,2),  -- prima_ant 
				DEC(16,2),  -- Porc_crec 
				DEC(16,2),  -- valor_prima 
				DEC(16,2),  -- pri_susc_dev_aa
				CHAR(7)     -- a_periodo 
				,CHAR(100)  -- cliente
				,CHAR(20)   -- poliza
				,CHAR(50);  -- ramo
				
			
DEFINE _cod_agente_ori       CHAR(5);  
DEFINE _n_agente_ori         CHAR(50); 
DEFINE _valor_prima_d           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _no_poliza       CHAR(10);

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
DEFINE _porcentaje   	 DEC(16,2);
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
define a_periodo2           char(7);
define _estatus_licencia    char(1);

--SET DEBUG FILE TO "che95c.trc";
--DROP TABLE tmpche95c ;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmpche95c
	(cia                CHAR(50),
	asegurado			CHAR(100),
	poliza				CHAR(20),
	prima_suscrita		DEC(16,2),
	prima_cob_dev		DEC(16,2),
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
	
CREATE TEMP TABLE tmprenta2ii
	(cia                CHAR(50),
	asegurado			CHAR(100),
	poliza				CHAR(20),
	prima_suscrita		DEC(16,2),
	prima_cob_dev		DEC(16,2),		
	siniestro			DEC(16,2),	
	ramo				CHAR(50),	
	agente				CHAR(100),	
	cod_agente			CHAR(5),
	prima_ant   		DEC(16,2),
	bono 				DEC(16,2),	
	porc_partic         DEC(5,2),
	valor_prima         DEC(16,2)
	)
	WITH NO LOG;

CREATE TEMP TABLE rentabilidad2tmp
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
	pri_dev_max_aa  	DEC(16,2))
	WITH NO LOG;	

let v_nombre_cia    = sp_sis01(a_cia); 
let _crecimiento    = 0;
let _Porc_crec      = 100;
let a_cia           = a_cia        ;
let a_cod_agente	= a_cod_agente ;	
let a_periodo		= a_periodo	   ;	
--let a_periodo		= "2016-02"	   ;

	insert into rentabilidad2tmp(
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
		   pri_dev_max_aa
		   )
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
		   pri_dev_max_aa
	  from rentabilidad2
	 where periodo = a_periodo;

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
		   pri_dev_max_aa
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
		   _pri_susc_dev_aa
	 from rentabilidad2tmp 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
	order by 1,2,3,4,5,6,7,8 desc	
  
	if  _prima_aa is null or _prima_aa = 0 then
		let _prima_aa = 0;
	end if

	if  _sini is null or _sini = 0 then
		let _sini = 0;
	end if
	
	let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
	let _nombre_cliente = trim(_n_cliente);

	if  _prima_aplica is null or _prima_aplica = 0 then
		let _prima_aplica = 0;
	end if

    insert into tmpche95c(cia,asegurado,poliza,prima_suscrita,siniestro,ramo,agente,cod_agente,prima_ant,prima_cob_dev)
	values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_sini,_nombre_ramo,_nombre_agente,_cod_agente,_prima_ant,_pri_susc_dev_aa);

END FOREACH

select ult_per_fidel into a_periodo2 from parparam;
let _valor_prima = 0;	


	

FOREACH
	select cia,agente,cod_agente,asegurado,poliza,ramo,prima_suscrita,prima_ant,siniestro,prima_cob_dev
		  into v_nombre_cia,_nombre_agente,_cod_agente,_nombre_cliente,_no_documento,_nombre_ramo,_prima_aa,_prima_ant,_sini,_pri_susc_dev_aa
		  from tmpche95c 		 
		 order by 1,2,3,4,5,6, 7 desc		 

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

		let _porcentaje  = 0;
		select estatus_licencia into _estatus_licencia from agtagent where cod_agente = _cod_agente;
		if _estatus_licencia <> "A" then
			let _nombre_agente = "* " || _nombre_agente;
		end if			 
		
		let _valor_prima = 0;																																		         
		let _valor_prima_d = 0;																																		         
		let _valor_prima = (_pri_susc_dev_aa * ( 55 / 100) - _sini) * 15 / 100;		
	    let _no_poliza = sp_sis21(_no_documento);
		
		foreach
	    select cod_agente,
		       porc_partic_agt
		  into _cod_agente_ori,
		       _porc_partic
		  from emipoagt
		 where no_poliza = _no_poliza
		 
		SELECT nombre
		  INTO _n_agente_ori
		  FROM agtagent 
		 WHERE cod_agente = _cod_agente_ori; 		 		 
		 
		 let _valor_prima_d = (_valor_prima * ( _porc_partic / 100) ) ;		
	
		insert into tmprenta2ii(cia,asegurado,poliza,prima_suscrita,siniestro,ramo,agente,cod_agente,prima_ant,prima_cob_dev,bono,porc_partic,valor_prima)
		values (v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_sini,_nombre_ramo,_n_agente_ori,_cod_agente_ori,_prima_ant,_pri_susc_dev_aa,_valor_prima,_porc_partic,_valor_prima_d);		 		
		
		end foreach


		RETURN  v_nombre_cia,
				_nombre_agente,
				_cod_agente, 
				_prima_aa, 
				_sini, 
				_prima_ant, 
				_Porc_crec, 
				--_sini, 
				_valor_prima,
				_pri_susc_dev_aa,
				a_periodo2,
				_nombre_cliente,_no_documento,_nombre_ramo
				WITH RESUME;	
	
END FOREACH

{FOREACH
	select cia,agente,cod_agente,sum(prima_suscrita),sum(prima_ant),sum(siniestro),sum(prima_cob_dev)
	  into v_nombre_cia,_nombre_agente,_cod_agente,_prima_aa,_prima_ant,_sini,_pri_susc_dev_aa
	  from tmpche95c 
	 group by 1,2,3 
	 order by 1,2, 3 desc

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

		let _porcentaje  = 0;
		select estatus_licencia into _estatus_licencia from agtagent where cod_agente = _cod_agente;
		if _estatus_licencia <> "A" then
			let _nombre_agente = "* " || _nombre_agente;
		end if	

		if _prima_aa >= 50000 And _Porc_crec >= 10 then

			let _valor_prima = 0;																																		         
			let _valor_prima = (_pri_susc_dev_aa * ( 55 / 100) - _sini) * 15 / 100;
			
			if _valor_prima < 0 then
				let _valor_prima = 0;																																		         
			end if			

			RETURN  v_nombre_cia,
					_nombre_agente,
					_cod_agente, 
					_prima_aa, 
					_sini, 
					_prima_ant, 
					_Porc_crec, 
					--_sini, 
					_valor_prima,
					_pri_susc_dev_aa,
					a_periodo2
					WITH RESUME;
        else
			let _valor_prima = 0;																																		         

			
			RETURN  v_nombre_cia,
					_nombre_agente,
					_cod_agente, 
					_prima_aa, 
					_sini, 
					_prima_ant, 
					_Porc_crec, 
					--_sini, 
					_valor_prima,
					_pri_susc_dev_aa,
					a_periodo2
					WITH RESUME;
		end if
	
END FOREACH}

DROP TABLE tmpche95c ;
DROP TABLE rentabilidad2tmp ;

END PROCEDURE;  
