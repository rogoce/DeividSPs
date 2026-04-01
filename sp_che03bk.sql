-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_che03bk;
CREATE PROCEDURE sp_che03bk(
a_compania 		 CHAR(3), 
a_sucursal 		 CHAR(3),
a_fecha_desde    DATE,
a_fecha_hasta    DATE,
a_cod_agente     CHAR(255)	
) RETURNING CHAR(20),	-- Poliza
			CHAR(100),	-- Asegurado
			CHAR(10),	-- Recibo
			DATE,		-- Fecha
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(5,2),	-- % Partic
			DEC(5,2),	-- % Comis
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50);	-- Compania

DEFINE _tipo          CHAR(1);

DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_partic  DEC(5,2); 
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
define _cnt_aplica	  smallint;
define _comision_adelanto	dec(16,2);
define _no_recibo	  CHAR(10);

DEFINE _cod_cliente  CHAR(10);

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta
);

CREATE TEMP TABLE tmp_salida(
	no_documento	CHAR(20),
	nombre_clte		CHAR(100),
	no_recibo		CHAR(10),
	fecha			DATE,
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision		DEC(16,2),
    nombre_agt      CHAR(50),
	nombre_cia      CHAR(50)
	) WITH NO LOG;
	
IF a_cod_agente <> "*" THEN

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	cod_agente,
 		no_poliza,
		no_recibo,
		fecha,
		monto,
		prima,
		porc_partic,
		porc_comis,
		comision,
		nombre,
		no_documento
   INTO	v_cod_agente,
   		v_no_poliza,
		v_no_recibo,
		v_fecha,
		v_monto,
		v_prima,
		v_porc_partic,
		v_porc_comis,
		v_comision,
		v_nombre_agt,
		v_no_documento
   FROM	tmp_agente
  WHERE seleccionado = 1
  ORDER BY nombre, fecha, no_recibo, no_documento

	IF v_no_poliza = '00000' THEN -- Comision Descontada

		LET v_nombre_clte = 'COMISION DESCONTADA ...';	

	ELSE

		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		--call sp_che137(v_no_documento) returning _error,_error_desc;

	END IF

-- Adelanto de Comision -- CASO: 15971 USER: ZULEYKA PC: CMCONT06

    let _cnt_aplica = 0;
-- CASO: 33614 USER: ZULEYKA Ya no habrá más adelanto Amado 22/01/2020
 {   if v_cod_agente = "00628" then
		select count(*)
		  into _cnt_aplica
		  from cobadeco
		 where no_documento = v_no_documento
		   and cod_agente	= v_cod_agente;
		
		if _cnt_aplica > 0  then 
			if v_no_poliza <> '00000' then
				select comision_adelanto,
					   no_recibo
				  into _comision_adelanto,
					   _no_recibo
				  from cobadeco
				 where cod_agente	= v_cod_agente
				   and no_documento = v_no_documento;

				if v_no_recibo = _no_recibo then
					let v_comision	= _comision_adelanto;
				else
					let v_comision	= 0.00;
				end if
			end if
		end if
	end if
}
    insert into tmp_salida(
	no_documento,
	nombre_clte,
	no_recibo,
	fecha,
	monto,
	prima,
	porc_partic,
	porc_comis,
	comision,
    nombre_agt,
	nombre_cia)
	values(
	v_no_documento,
	v_nombre_clte,
	v_no_recibo,
	v_fecha,
	v_monto,
	v_prima,
	v_porc_partic,
	v_porc_comis,
	v_comision,
	v_nombre_agt,
	v_nombre_cia
	);
	
	{RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
			WITH RESUME;}
	
END FOREACH

foreach

	SELECT cod_agente
	  into v_cod_agente
	  from tmp_agente
	 where seleccionado = 1
     group by cod_agente	 

    foreach
	
		select no_documento,
		       fecha,
			   comision,
			   no_recibo,
			   no_poliza,
			   nombre
		  into v_no_documento,
		       v_fecha,
			   v_comision,
			   v_no_recibo,
			   v_no_poliza,
			   v_nombre_agt
		  from chqcomis
		 where cod_agente = v_cod_agente
		   and fecha_desde = a_fecha_desde
		   and fecha_hasta = a_fecha_hasta
		   and bono_salud  = 1
		   
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		insert into tmp_salida(
			no_documento,
			nombre_clte,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre_agt,
			nombre_cia)
			values(
			v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			0,
			0,
			0,
			0,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
			);		 
		   
	   { RETURN  v_no_documento,
				v_nombre_clte,
				v_no_recibo,
				v_fecha,
				0,
				0,
				0,
				0,
				v_comision,
				v_nombre_agt,
				v_nombre_cia
			WITH RESUME;}
	end foreach
end foreach

foreach
	select  no_documento,
			nombre_clte,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre_agt,
			nombre_cia
	 into   v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
	 from   tmp_salida
	ORDER BY nombre_agt, fecha, no_recibo, no_documento
	
	RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
			WITH RESUME;
end foreach

--DROP TABLE tmp_agente;
--DROP TABLE tmp_salida;

END PROCEDURE;