-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza
-- SD#4504: 14/09/2022 - Autor: HGIRON

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che03;
CREATE PROCEDURE sp_che03(a_compania CHAR(3),a_sucursal CHAR(3),a_fecha_desde DATE,a_fecha_hasta DATE,a_cod_agente CHAR(255),a_grupo CHAR(255) DEFAULT "*")
RETURNING   CHAR(20)  as v_poliza,	-- Poliza
			CHAR(100) as v_asegurado,	-- Asegurado
			CHAR(10)  as v_recibo,	-- Recibo
			DATE      as v_fecha,		-- Fecha
			DATE      as vig_inicial,		-- Vigencia_inicial			
			DEC(16,2) as v_monto,	-- Monto
			DEC(16,2) as v_prima,	-- Prima
			DEC(5,2)  as v_porc_partic,	-- % Partic
			DEC(5,2)  as v_porc_comis,	-- % Comis
			DEC(16,2) as v_comision,	-- Comision
			CHAR(50)  as v_nombre_agente,   -- Agente
			CHAR(50)  as compania,	-- Compania
			CHAR(255) as v_filtros,  -- filtros
			char(50)  as sucursal;
			
DEFINE _tipo          	CHAR(1);

DEFINE v_cod_agente   	CHAR(5);  
DEFINE v_no_poliza    	CHAR(10); 
DEFINE v_monto        	DEC(16,2);
DEFINE v_no_recibo    	CHAR(10); 
DEFINE v_fecha        	DATE;     
DEFINE v_prima        	DEC(16,2);
DEFINE v_porc_partic  	DEC(5,2); 
DEFINE v_porc_comis   	DEC(5,2); 
DEFINE v_comision     	DEC(16,2);
DEFINE v_nombre_clte  	CHAR(100);
DEFINE v_no_documento 	CHAR(20);
DEFINE v_nombre_agt   	CHAR(50);
DEFINE v_nombre_cia   	CHAR(50);
define _cnt_aplica	  	smallint;
define _comision_adelanto	dec(16,2);
define _no_recibo	  	CHAR(10);
DEFINE v_filtros        CHAR(255);
DEFINE _cod_cliente  	CHAR(10);
DEFINE v_saber  		CHAR(10);
define v_desc_grupo  	varchar(50);
define v_codigo     	char(5);
define _cod_sucursal   	char(3);
define _n_sucursal     	char(50);
define _cadena   		CHAR(255); 
DEFINE _vig_ini		  	DATE;
define _no_requis		CHAR(10);
define _no_cheque   	integer;
define _tipo_requis 	CHAR(1);
DEFINE _comision	  	DEC(16,2);
define _fecha_ini 		DATE;
DEFINE _fecha_captura	DATE;

LET v_saber = "";
LET _cadena = ""; 

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01(a_compania); 
LET v_filtros = "";
LET _vig_ini = null;

CALL sp_che02(a_compania, a_sucursal, a_fecha_desde, a_fecha_hasta);

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
	nombre_cia      CHAR(50),
	vig_ini         date
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

IF a_grupo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) || " Grupo: "; -- ||TRIM(a_grupo);
	LET _tipo = sp_sis04(a_grupo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";
	ELSE		        -- Excluir estos Registros
		UPDATE tmp_agente
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_grupo IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";
	END IF
    FOREACH
		SELECT cligrupo.nombre,tmp_codigos.codigo
	      INTO v_desc_grupo,v_codigo
	      FROM cligrupo,tmp_codigos
	     WHERE cligrupo.cod_grupo = codigo

		 LET _cadena = LENGTH(TRIM(v_filtros)) + LENGTH(TRIM(v_codigo)) + LENGTH(TRIM(v_desc_grupo));

		 IF  _cadena <= 255	THEN
	        LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_grupo) || (v_saber);
		 END IF

    END FOREACH
	DROP TABLE tmp_codigos;
END IF
SET ISOLATION TO DIRTY READ;
FOREACH
	SELECT cod_agente,
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
	  INTO v_cod_agente,
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
	  FROM tmp_agente
	 WHERE seleccionado = 1
  ORDER BY nombre, fecha, no_recibo, no_documento

	IF v_no_poliza = '00000' THEN -- Comision Descontada
		LET v_nombre_clte = 'COMISION DESCONTADA ...';	
	ELSE
		SELECT cod_contratante, vigencia_inic
		  INTO _cod_cliente,_vig_ini
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
	
	if v_cod_agente = "00628" then
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
	nombre_cia,vig_ini)
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
	v_nombre_cia,_vig_ini
	);
	--end if
END FOREACH

LET _no_requis = NULL;

foreach
	SELECT cod_agente
	  into v_cod_agente
	  from tmp_agente
	 where seleccionado = 1
     group by cod_agente

	select fecha_ini
	  into _fecha_ini
	  from chqpagco
	 where fecha_desde = a_fecha_desde
	   and fecha_hasta = a_fecha_hasta;

	select no_requis,
		   SUM(comision)
	  into _no_requis,
		   _comision
	  from chqcomis	  
	 where cod_agente = v_cod_agente
	   and fecha_desde = a_fecha_desde
	   and fecha_hasta = a_fecha_hasta
	group by no_requis;
	 	   	   
	if (_no_requis is not null or trim(_no_requis) <> '') AND _comision > 0 then
		select fecha_captura
		  into _fecha_captura
		  from chqchmae
		 where no_requis = _no_requis;
		 
		if _fecha_ini <> _fecha_captura then
			continue foreach;
		end if

	    foreach
			select no_documento,
				   fecha,
				   comision,
				   no_recibo,
				   no_poliza,
				   nombre,
				   monto,
				   prima,
				   porc_partic,
				   porc_comis
			  into v_no_documento,
				   v_fecha,
				   v_comision,
				   v_no_recibo,
				   v_no_poliza,
				   v_nombre_agt,
				   v_monto,
				   v_prima,
				   v_porc_partic,
				   v_porc_comis
			  from chqcomis
			 where no_requis = _no_requis
			  
{			 where cod_agente = v_cod_agente
			   and fecha_desde = a_fecha_desde
			   and fecha_hasta = a_fecha_hasta
			   and no_requis is not null
		--	   and bono_salud  = 1
}	
			IF v_no_poliza = '00000' THEN -- Comision Descontada

				LET v_nombre_clte = 'COMISION DESCONTADA ...';	

			ELSE

				SELECT cod_contratante, vigencia_inic
				  INTO _cod_cliente,_vig_ini
				  FROM emipomae
				 WHERE no_poliza = v_no_poliza;

				SELECT nombre
				  INTO v_nombre_clte
				  FROM cliclien
				 WHERE cod_cliente = _cod_cliente;

			END IF

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
				nombre_cia,vig_ini)
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
				v_nombre_cia,_vig_ini
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
	End If
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
			nombre_cia,
			vig_ini
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
			v_nombre_cia,
			_vig_ini
	 from   tmp_salida
	ORDER BY nombre_agt, fecha, no_recibo, no_documento
	
	foreach
		select no_poliza 
		  into v_no_poliza
		  from tmp_agente 
		 WHERE trim(nombre) = trim(v_nombre_agt)
		   AND no_documento = v_no_documento
		   AND no_recibo    = v_no_recibo
		   AND fecha        = v_fecha
		   
		exit foreach;
	end foreach
		   
    if v_no_poliza is null or v_no_poliza = '000000' or trim(v_no_poliza) = ''  then
		let _vig_ini = null;
    else 
		SELECT vigencia_inic,
		       cod_sucursal
		  INTO _vig_ini,
		       _cod_sucursal
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;
		 
		select descripcion
		  into _n_sucursal
		  from insagen
		 where codigo_agencia = _cod_sucursal;
	end if
	
	RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			_vig_ini,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			v_filtros,
			_n_sucursal
			WITH RESUME;
end foreach

DROP TABLE tmp_agente;
DROP TABLE tmp_salida;

END PROCEDURE 
                    