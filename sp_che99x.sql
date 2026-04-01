-- Reporte de los Bonificacion de Rentabilidad  - TOTALES X RAMO
-- Creado    : 16/02/2009 - Autor: Henry Giron
-- Modificado: 16/02/2009 - Autor: Henry Giron

DROP PROCEDURE sp_che99x;
CREATE PROCEDURE sp_che99x(a_compania CHAR(3), a_cod_agente CHAR(5) default '*', a_periodo char(7)) 
  RETURNING CHAR(20),	-- Poliza	  
			CHAR(100),	-- Asegurado  
			DEC(16,2),	-- Monto	  
			DEC(16,2),	-- Prima	  
			DEC(16,2),	-- Comision	   
			CHAR(50),  
			CHAR(50),  			   
			DEC(16,2),  			   
			DEC(16,2), 	   
			DEC(16,2),  	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2), 	   
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			CHAR(3),
			DEC(16,2),
			CHAR(50),
			CHAR(3),
			CHAR(50),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);


DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(16,2); 
DEFINE v_porc_cre	  DEC(16,2); 
DEFINE v_porc_sin	  DEC(16,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE _fecha_comis   DATE;
define _porc_persis   DEC(16,2);
define _porcentaje    DEC(16,2);
define _estatus_licencia char(1);
define _cod_ramo,_tipo1	  char(3);
define _prima_ap      DEC(16,2);
define _nombre_ramo,_nombre_tipo   CHAR(50);
define _cantidad smallint;

define  _cod_ramo1    char(3);
define  _nombre_ramo1 CHAR(50);
define  _prima_ap1    DEC(16,2);
define  _prima_neta1  DEC(16,2);
define  _prima_ap2    DEC(16,2);
define  _prima_neta2  DEC(16,2);
define  _comision1    DEC(16,2);
define  _sini_g       DEC(16,2);
define  _sini         DEC(16,2); 
define  _sini_inc     DEC(16,2);


--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

SET ISOLATION TO DIRTY READ;

let	_porc_persis = 0;
let	_porcentaje = 0;
let _cantidad = 0;

FOREACH
    SELECT	 chqrenta4.no_documento,
			 chqrenta4.n_cliente,
	         chqrenta4.cod_ramo,
			 chqrenta4.nombre_ramo,
			 chqrenta4.n_agente,
			 chqrenta4.tipo,
			 +chqrenta4.pri_pag_ap + chqrenta4.pri_can_ap - chqrenta4.pri_dev_ap - chqrenta4.monto_90_ap,
			 +chqrenta4.pri_pag_aa + chqrenta4.pri_can_aa - chqrenta4.pri_dev_aa - chqrenta4.monto_90_aa,
		     chqrenta4.sini_inc
   		INTO v_no_documento,
			 v_nombre_clte,
        	 _cod_ramo1,
			 _nombre_ramo1,
			 v_nombre_agt,
			 _tipo1,
			 _prima_ap2,
			 _prima_neta2,
			 _sini_inc
		from chqrenta4  
		where chqrenta4.cod_agente  matches a_cod_agente --= '00874'
          and chqrenta4.periodo      = a_periodo
		  and (	(+chqrenta4.pri_pag_ap + chqrenta4.pri_can_ap - chqrenta4.pri_dev_ap - chqrenta4.monto_90_ap) <> 0
		   or (+chqrenta4.pri_pag_aa + chqrenta4.pri_can_aa - chqrenta4.pri_dev_aa - chqrenta4.monto_90_aa) <> 0)
		   and chqrenta4.tipo in ('A','C')
		order by chqrenta4.cod_agente,chqrenta4.cod_ramo						

			let _cantidad = 0;
			SELECT count(*)
			  INTO _cantidad
			  from chqrenta5
			 where chqrenta5.cod_agente matches a_cod_agente -- = '00874'
			   and chqrenta5.periodo     = a_periodo
			   and chqrenta5.cod_ramo    = _cod_ramo1 
			   and chqrenta5.tipo_g      = _tipo1;

		if 	_cantidad <> 0 then

		    SELECT	chqrenta5.cod_agente,
		 		chqrenta5.no_poliza,
				chqrenta5.prima_neta_g,
				chqrenta5.comision_g,
				chqrenta5.por_persistencia,
				chqrenta5.porcentaje_g,
				chqrenta5.por_cre_g,
				chqrenta5.por_sin_g,
				chqrenta5.tipo_g,
				chqrenta5.prima_ap_g,
				chqrenta5.nombre_tipo_g,
				chqrenta5.prima_ap,		 -- simple
				chqrenta5.prima_neta,	 -- simple
				chqrenta5.comision,
				chqrenta5.sini_g
   		   		INTO  v_cod_agente,
					v_no_poliza,
					v_prima,
					v_comision,
					_porc_persis,
					_porcentaje,
					v_porc_cre,
					v_porc_sin,
					_tipo,
					_prima_ap,
					_nombre_tipo,
					_prima_ap1,
					_prima_neta1,
					_comision1,
					_sini_g
				 from chqrenta5
				where chqrenta5.cod_agente matches a_cod_agente -- = '00874'
		          and chqrenta5.periodo    = a_periodo
				  and chqrenta5.cod_ramo   = _cod_ramo1 
				  and chqrenta5.tipo_g     = _tipo1;

				select sum(comision)
				  into v_comision
				  from chqrenta5
				 where cod_agente matches a_cod_agente --= '00874' --v_cod_agente
				   and periodo            = a_periodo
				   and chqrenta5.cod_ramo = _cod_ramo1 
				   and chqrenta5.tipo_g   = _tipo1;

	   else	 
   				let v_cod_agente = "";
	   			let v_no_poliza = "";
				let v_prima = 0;
				let v_comision = 0;
				let _porc_persis = 0;
				let _porcentaje = 0;
	        	let v_porc_cre = 0;
	        	let v_porc_sin = 0;
 				let _prima_ap = 0;
				let _prima_ap1 = 0;
				let _prima_neta1 = 0;
				let _comision1 = 0;
			    let _sini_g = 0;
				let _sini = 0;
				--let _sini_inc = 0;

				select sum(pri_sus_pag_ap), -- Prima_anterior
					   sum(pri_sus_pag_aa), -- Prima_actual
					   sum(sini_inc)        --siniestro
				  into _prima_ap1,
					   _prima_neta1,
					   _sini
				  from chqrenta4
				 where periodo    = a_periodo
				   and cod_agente matches a_cod_agente
				   and cod_ramo   = _cod_ramo1 
				   and tipo = _tipo1;

				select sum(pri_sus_pag_ap), -- Prima_anterior
					   sum(pri_sus_pag_aa), -- Prima_actual
					   sum(sini_inc)        -- siniestro
				  into _prima_ap,
					   v_prima,
					   _sini_g
				  from chqrenta4
				 where periodo    = a_periodo
				   and cod_agente matches a_cod_agente
				   and tipo = _tipo1;

				let v_comision      = 0;
				let _porcentaje     = 0;
				let v_porc_cre    = 0;
				let v_porc_sin = 0; 			
			
				--************************************************
				--   Calculos % de crecimiento de PSP
				--************************************************
				if v_prima <> 0 then
					let v_porc_cre = ((v_prima - _prima_ap) / _prima_ap) * 100;
				end if

				if v_porc_cre = 0 then
					let v_porc_cre = 100;
				end if

				--************************************************
				--    Calculos % de siniestralidad 2008	
				--************************************************
				let v_porc_sin = 0;
				if v_prima <> 0 then
					let v_porc_sin = (_sini_g / v_prima) * 100;
				end if	


		end if

		if v_comision is null then
		   let v_comision = 0.00;
		end if

		if _porcentaje is null then
		   let _porcentaje = 0.00;
		end if

		if  _tipo1 = 'A' then 
		  let _nombre_tipo = 'AUTOMOVIL'  ;
		end if
		if  _tipo1 = 'B' then 
		  let _nombre_tipo = 'SALUD'  ;
		end if
		if  _tipo1 = 'C' then 
		  let _nombre_tipo = 'PATRIMONIAL'  ;
		end if
		if _tipo1 = 'D' then 
		  let _nombre_tipo = 'PERSONAS'  ;
		end if
		if  _tipo1 = 'E' then 
		  let _nombre_tipo = 'FIANZAS'  ;
		end if		

		let _cod_ramo =  _tipo1;
		let	_nombre_ramo = _nombre_tipo;


	RETURN  v_no_documento,
			v_nombre_clte,
			0,
			v_prima,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			_porcentaje,
			v_comision,
			_porc_persis,
			_prima_ap2,
			_prima_neta2,
			_sini_g,
			_sini,
			_sini_inc,
			0,
            v_porc_cre,
            v_porc_sin,
			_cod_ramo,
		    _prima_ap,
		    _nombre_ramo,
			_cod_ramo1,
			_nombre_ramo1,
			_prima_ap1,
			_prima_neta1,
			_comision1
			WITH RESUME;

	
END FOREACH


END PROCEDURE;