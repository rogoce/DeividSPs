-- Informe de Reclamos por Ramo
-- 
-- Creado    : 02/12/2021 Autor: Armando Moreno Montenegro
--

--execute PROCEDURE sp_rec3a1('001','2021-01','2021-01',"*","002,023,020;","*","*","%","*")
DROP PROCEDURE sp_rec3a1b;
CREATE PROCEDURE sp_rec3a1b(
a_compania  CHAR(3),
a_periodo1  CHAR(7),
a_periodo2  CHAR(7),
a_sucursal  CHAR(255) DEFAULT "*", 
a_ramo      CHAR(255) DEFAULT "*",
a_ajustador CHAR(255) DEFAULT "*",
a_agente    CHAR(255) DEFAULT "*",
a_origen    CHAR(3)   DEFAULT "%",
a_evento    CHAR(255) DEFAULT "*"
) 
RETURNING CHAR(18) as reclamo,
          CHAR(20) as poliza,
		  date as vigencia_inic,
		  date as vigencia_final,
		  DATE as fecha_suscripcion,
		  DATE as fecha_siniestro,
		  DATE as fecha_reclamo,
		  CHAR(100) as asegurado,
		  varchar(60) as cobertura_afectada ,
		  varchar(60) as producto,
		  dec(16,2) as pagado,
		  dec(16,2) as deducible,
		  CHAR(10) as estatus_reclamo,
		  char(18) as estatus_poliza,
		  varchar(60) as corredor,
		  char(8) as tipo_rec,
		  char(10) as marca,
		  char(10) as modelo,
		  char(8) as placa,
		  smallint as ano_auto,
          char(1) as tipo_auto,
		  dec(16,2) as saldo_reserva,
		  varchar(255) as detalle,
		  date as cierre_reclamo;

DEFINE v_filtros         		CHAR(255);
DEFINE v_numrecla,_n_estatus        		CHAR(18);
DEFINE v_no_poliza,_no_documento       		CHAR(20);
DEFINE v_asegurado       		CHAR(100);
DEFINE v_fecha_siniestro,_fec_susc,_fecha_tipo,_fecha_flag,_fecha_cierre 		DATE;     
DEFINE v_fecha_reclamo,_vigencia_inic,_vigencia_final DATE;
DEFINE v_fecha_documento        DATE;    
DEFINE v_ramo_nombre     		CHAR(50);
DEFINE v_compania_nombre 		CHAR(50);
DEFINE v_ajustador				CHAR(50);
DEFINE v_status,_cod_marca,_cod_modelo,_placa,_no_reclamo,_cod_cobertura,_cod_producto,_no_poliza      CHAR(10);
DEFINE _estatus_pol,_perd_total,_ano_auto             smallint;
DEFINE _periodo          		CHAR(7);
DEFINE _cod_ramo,_ajust_interno CHAR(3);
define _no_motor                char(30);
DEFINE _estatus_reclamo,_uso_auto			CHAR(1);
define  _perd_total_s           char(8);
define _desc,_n_corredor,_n_cober,_n_prod                    varchar(60);
define _desc2                   varchar(255);
define _pagado,_deducible,_reserva_actual dec(16,2);
define _n_marca,_n_modelo char(50);
define _no_unidad,_cod_agente char(5);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec02_aud(
a_compania,
'001',
a_periodo1, 
a_periodo2,
a_sucursal,
a_ajustador,
'*', 
a_ramo,
a_agente
);

let _pagado =0;
let _cod_agente = '';
FOREACH 
	SELECT numrecla,        
	       no_poliza,       
	       asegurado,       
		   fecha_siniestro, 
		   fecha_reclamo, 
		   fecha_documento,  
		   cod_ramo,        
		   periodo,
		   no_reclamo
	  INTO v_numrecla,        
		   v_no_poliza,       
		   v_asegurado,       
		   v_fecha_siniestro, 
		   v_fecha_reclamo,
		   v_fecha_documento,
		   _cod_ramo,
		   _periodo,
		   _no_reclamo
	  FROM tmp_sinis
	 WHERE seleccionado = 1
	 ORDER BY cod_ramo, periodo, numrecla
	 
	SELECT ajust_interno,
		   estatus_reclamo,
		   no_documento,
		   no_unidad,
		   perd_total,
		   no_poliza
	  INTO _ajust_interno,
		   _estatus_reclamo,
		   _no_documento,
		   _no_unidad,
		   _perd_total,
		   _no_poliza
	  FROM recrcmae
	 WHERE numrecla = v_numrecla
	   AND actualizado = 1;
	   
	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
			exit foreach;
	end foreach
  
    select nombre
	  into _n_cober
	  from prdcober
     where cod_cobertura = _cod_cobertura;
  
	if _perd_total = 0 then
		let _perd_total_s = 'PARCIAL';
	else
		let _perd_total_s = 'TOTAL';
	end if
	
    select cod_producto
 	  into _cod_producto
	  from emipouni
     where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	select no_motor,
	       uso_auto
	  into _no_motor,
	       _uso_auto
	  from emiauto
     where no_poliza = _no_poliza
       and no_unidad = _no_unidad;

	select cod_marca,
	       cod_modelo,
		   placa,
		   ano_auto
	  into _cod_marca,
           _cod_modelo,
		   _placa,
		   _ano_auto
	  from emivehic
	 where no_motor = _no_motor;

    select nombre
      into _n_marca
      from emimarca
	 where cod_marca = _cod_marca;
	 
    select nombre
      into _n_modelo
      from emimodel
	 where cod_marca  = _cod_marca
	   and cod_modelo = _cod_modelo;

    select nombre
	  into _n_prod
	  from prdprod
     where cod_producto = _cod_producto;
   
	SELECT nombre
	  INTO v_ajustador
	  FROM recajust
	 WHERE cod_ajustador = _ajust_interno;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo 
	 WHERE cod_ramo = _cod_ramo;

	SELECT vigencia_inic,
	       vigencia_final,
		   fecha_suscripcion,
		   estatus_poliza
	  INTO _vigencia_inic,
	       _vigencia_final,
		   _fec_susc,
		   _estatus_pol
	  FROM emipomae 
	 WHERE no_poliza = _no_poliza;
	 
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
			exit foreach;
	end foreach
	
	select nombre
	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente; 

	IF _estatus_reclamo = 'A' THEN
		LET v_status =	'ABIERTO';
	ELIF _estatus_reclamo = 'C' THEN
		LET v_status =	'CERRADO';
	ELIF _estatus_reclamo = 'R' THEN
		LET v_status =	'RE-ABIERTO';
	ELIF _estatus_reclamo = 'T' THEN
		LET v_status =	'EN TRAMITE';
	ELIF _estatus_reclamo = 'D' THEN
		LET v_status =	'DECLINADO';
	ELIF _estatus_reclamo = 'N' THEN
		LET v_status =	'NO APLICA';
	END IF
	
	SELECT sum(monto)
      INTO _pagado
	  FROM rectrmae
	 WHERE cod_compania = '001'
	   AND actualizado  = 1
	   AND cod_tipotran = '004'
	   AND no_reclamo   = _no_reclamo
	--   AND periodo      >= a_periodo1 
	   AND periodo      <= a_periodo2
	   AND monto        <> 0;
	   
	SELECT SUM(x.deducible),
		   SUM(x.reserva_actual)
      INTO _deducible,
		   _reserva_actual
	  FROM recrccob x, recrcmae y
	 WHERE x.no_reclamo  = y.no_reclamo
	   AND y.no_reclamo  = _no_reclamo;
	
	let _desc = '';
	let _desc2 = '';
    foreach
		select desc_transaccion
		  into _desc
		  from recrcde2
		 where no_reclamo = _no_reclamo

        let _desc2 = _desc2 || _desc;		 
	end foreach

	let _fecha_flag = '01/01/1900';
	let _fecha_tipo = '01/01/1900';
	
	select max(fecha)
	  into _fecha_flag
	  from rectrmae
	 where actualizado = 1
	   and cerrar_rec  = 1
       and no_reclamo = _no_reclamo;
	   
	select max(fecha)
	  into _fecha_tipo
	  from rectrmae
	 where actualizado = 1
       and no_reclamo = _no_reclamo
	   and cod_tipotran = '011';
	   
	if _fecha_tipo >= _fecha_flag then
		let _fecha_cierre = _fecha_tipo;
	else
		let _fecha_cierre = _fecha_flag;
	end if
	let _n_estatus = '';
	if _estatus_pol = 1 then
	   let _n_estatus = 'Vigente';
	elif _estatus_pol = 2 then
	   let _n_estatus = 'Cancelada';
    elif _estatus_pol = 3 then
	   let _n_estatus = 'Vencida';
    elif _estatus_pol = 4 then
	   let _n_estatus = 'Anulada';
	end if   
	   
	RETURN v_numrecla,        
		   _no_documento,
		   _vigencia_inic,
	       _vigencia_final,
		   _fec_susc,
		   v_fecha_siniestro,
		   v_fecha_reclamo,
		   v_asegurado,       
		   _n_cober,
		   _n_prod,
		   _pagado,
		   _deducible,
		   _estatus_reclamo,
		   _n_estatus,
		   _n_corredor,
		   _perd_total_s,
		   _n_marca,
		   _n_modelo,
		   _placa,
		   _ano_auto,
		   _uso_auto,
		   _reserva_actual,
		   _desc2,
		   _fecha_cierre
		   WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;                                                   
END PROCEDURE;