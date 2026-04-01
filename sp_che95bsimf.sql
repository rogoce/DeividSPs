-- Reporte de los Bonificacion de Rentabilidad 2011
-- Creado    : 24/02/2011 - Autor: Henry Giron
-- Modificado: 24/02/2011 - Autor: Henry Giron

--DROP PROCEDURE sp_che95bsimf;
CREATE PROCEDURE sp_che95bsimf(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
RETURNING CHAR(50),CHAR(100),CHAR(20),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(50),CHAR(50),CHAR(100),DEC(16,2),DEC(16,2);

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
DEFINE _reserva_ant      DEC(16,2);
DEFINE _porc_res_mat   	 DEC(16,2);
DEFINE _prima_aplica   	 DEC(16,2);
DEFINE _prima_ant   	 DEC(16,2);
DEFINE _estatus_licencia CHAR(1);

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
	agente				CHAR(100),
	reserva_ant			DEC(16,2),
	prima_sus_ant       DEC(16,2))
	WITH NO LOG;

CREATE TEMP TABLE chqrenta030212b
	(cia                CHAR(50),
	periodo             CHAR(7),
	no_documento        CHAR(20),
	cod_agente          CHAR(5),
	n_agente			CHAR(100),
	tipo                CHAR(3),
	categoria			CHAR(100),
	nombre_ramo			CHAR(50),
	pri_sus_pag_ap		DEC(16,2),
	pri_sus_pag_aa		DEC(16,2),
	n_cliente			CHAR(100),
	cod_ramo			CHAR(3),
	monto_90_aa			DEC(16,2),
	sini_inc			DEC(16,2))
	WITH NO LOG;

let v_nombre_cia = sp_sis01(a_cia); 
let _crecimiento = 0;
let _Porc_crec   = 100;
let _reserva_ant = 0;
let _prima_ant   = 0;
let _reserva     = 0;
let _prima_aplica = 0;

if a_periodo >= "2021-12" then
	insert into chqrenta030212b(
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
		   sini_inc)	   
	select v_nombre_cia,
	       periodo,
		   trim(no_documento),
	       trim(cod_agente),
	       trim(n_agente),
	       trim(tipo),
		   trim(nombre_ramo),
	       pri_susc_ap,
	       pri_susc_aa,
		   trim(n_cliente),
		   cod_ramo,
		   pri_susc_dev_ap,
		   sini_inc
	  from rentabilidad11
	 where periodo = a_periodo;
else
	insert into chqrenta030212b(
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
		   sini_inc
		   )
	select v_nombre_cia,				 
	       periodo,						 
		   trim(no_documento),			 
	       trim(cod_agente),			 
	       trim(n_agente),				 
	       trim(tipo),					 
		   trim(nombre_ramo),			 
	       pri_sus_pag_ap,				 
	       pri_sus_pag_aa,
		   n_cliente,	
		   cod_ramo,	
		   pri_dev_ap,
	       sini_inc
	  from chqrenta						 
	 where periodo = a_periodo;
end if

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
		   _monto_90,		--prima suscrita devengada
		   _sini,
		   _prima_ant
	  from chqrenta030212b 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
	order by 1,2,3,4,5,6,7,8 desc
  
	if _prima_aa is null then
		let _prima_aa = 0;
	end if
	let _prima_exc_m90 = _prima_aa;

	if _monto_90 is null then
		let _monto_90 = 0;
	else
		let _prima_exc_m90 = 0;
	end if
	if _sini is null then
		let _sini = 0;
	end if

	select porc_res_mat
	  into _porc_res_mat
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if  _porc_res_mat is null or _porc_res_mat = 0 then
		let _porc_res_mat = 100;
	end if

	let _porc_res_mat = 100 - _porc_res_mat;

	if  _porc_res_mat is null or _porc_res_mat = 0 then
		let _porc_res_mat = 100;
	end if

	if a_periodo >= "2011-12" then
		--let _prima_aplica = _prima_exc_m90 - _reserva + _reserva_ant;
	else
		let _prima_aplica = _prima_exc_m90 * _porc_res_mat / 100;
	end if

	if  _prima_aplica is null or _prima_aplica = 0 then
		let _prima_aplica = 0;
	end if

	let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
	LET _nombre_cliente = trim(_n_cliente);

	select estatus_licencia into _estatus_licencia from agtagent where cod_agente = _cod_agente;
	if trim(_estatus_licencia) <> "A" then
		let _nombre_agente = "* " || trim(_n_agente)||" "||_cod_agente;
		let _nombre_agente = trim(_nombre_agente);
	end if
	select trim(name_tipo)
	  into _nombre_tipo
	  from prdrenttipo 
	 where periodo  = a_periodo
	   and cod_tipo = _cod_tipo 
	   and activo   = 1;

	insert into tmpche95b(prima_sus_ant,cia,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,categoria,ramo,agente,reserva_ant)
	values (_prima_ant,v_nombre_cia,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_nombre_tipo,_nombre_ramo,_nombre_agente,_reserva_ant);			 

END FOREACH


FOREACH
	select cia,agente,categoria,ramo,asegurado,poliza,prima_suscrita,monto_90,prima_exc_monto90,reserva,prima_exc_reserva,siniestro,reserva_ant,prima_sus_ant
	  into v_nombre_cia,_nombre_agente,_nombre_tipo,_nombre_ramo,_nombre_cliente,_no_documento,_prima_aa,_monto_90,_prima_exc_m90,_reserva,_prima_aplica,_sini,_reserva_ant,_prima_ant
	  from tmpche95b 
	 order by 1,2,3,4,5,6,7 desc


	RETURN  v_nombre_cia,
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
			_nombre_agente,
			_reserva_ant,
			_prima_ant
			 WITH RESUME;	
	
END FOREACH

DROP TABLE tmpche95b ;
DROP TABLE chqrenta030212b ;
END PROCEDURE;  
