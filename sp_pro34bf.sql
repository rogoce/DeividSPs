-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   06/09/2001                         inclusion de filtro de poliza
-- Modificado: 15/09/2010 - Roman Gordon (inclusion de columnas y filtro por fecha)
-- Modificado: 23/04/2018  - Autor: Henry Giron (Filtro por Zona), DALBA
--execute procedure sp_pro34bf('001','001','2023-01','2023-12',"*","*","*","*","*","*",'1',"*","*",'01/01/2023','31/12/2023',0,"*") 

drop procedure sp_pro34bf;
create procedure sp_pro34bf(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_codagente		char(255)	default "*",
a_codusuario	char(255)   default "*",
a_codramo		char(255)	default "*",
a_reaseguro		char(255)	default "*",
a_tipopol		char(1),
a_cod_cliente	char(255)	default "*",
a_no_documento	char(255)	default "*",
a_fecha1		date,
a_fecha2		date,
a_por_fecha		smallint	default 0,
a_codvend       CHAR(255)   default "*") 
returning	char(3),
			char(50),
			char(10),
			char(13),
			char(10),
			char(50),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(9,2),
			char(2),
			char(3),
			smallint,
			char(50),
			char(255),
			smallint,
			varchar(50),
			char(6),
			char(50),
			char(12),
			date,
			date,
			varchar(50),
			varchar(8),
			varchar(50),
			char(2),
			varchar(50),
			char(7),
			date,
			date;

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20); 
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod,_cod_vendedor  CHAR(03);
      DEFINE v_cod_usuario,_cod_usu                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   dec(16,2);
      DEFINE v_comision                      dec(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(1);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago,_cod_tipoprod      CHAR(3);
	  define _periodo						 char(7);
      DEFINE v_cant_pagos,_cnt_emifafac      SMALLINT;
      DEFINE v_descr_cia,v_desc_agente       CHAR(50);
	  define v_cod_agente					 char(5);
	  define v_nueva_renov					 char(1);
	  define v_nomuser,_n_tipoprod			 varchar(50);
	  define _user							 varchar(15);
	  define _desc_endoso					 char(6);
	  define v_sucursal						 char(50);
	  define _desc_nueva_renov				 char(12);
	  define _fecha_impresion				 date;
	  define _fecha_emision					 date;
	  define _nom_agente,_n_vendedor_gen	 varchar(50);
	  define _estatus_poliza		         smallint;
	  define _estatus_nom2	                 char(10); 	  
	  define _prima_neta		             dec(16,2);
      DEFINE _cnt_pag                        SMALLINT;
      DEFINE _pag_1_letra,_facultativo       CHAR(2);	  	  
      DEFINE v_nodocumento_xls               CHAR(13);
	  define _vig_ini,_vig_fin				 date;
	  DEFINE _monto_pen                      dec(16,2);
	  define v_saber                         char(3);
	  
	  --  Status Póliza, Prima Neta, Primer Pago (Si/No). 	SD#1746 Dfernad  

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;
	  LET _estatus_nom2     = '';
	  LET _prima_neta       = 0.00;
      LET _cnt_pag          = 0;      
	  LET _pag_1_letra      = '';	  	  
	  LET v_desc_nombre     = '';	  	  	  
	  LET v_nodocumento_xls = '';	  	  	  
	  

      LET v_descr_cia = sp_sis01(a_compania);

	  IF a_por_fecha=1 THEN
		  CALL sp_pro193f(a_compania,a_agencia,a_fecha1,a_fecha2,a_codsucursal,a_codgrupo,a_codagente,
		                 a_codusuario,a_codramo,a_reaseguro, a_tipopol,a_codvend)
		                 RETURNING v_filtros;
	  ELSE
	      CALL sp_pro34f(a_compania,a_agencia,a_periodo1,a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
	                    a_codusuario,a_codramo,a_reaseguro, a_tipopol,a_codvend)
	                    RETURNING v_filtros;
	  END IF

	 --Llamada original sin el filtro por fecha
     -- CALL sp_pro34(a_compania,a_agencia,a_periodo1,
       --             a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
         --           a_codusuario,a_codramo,a_reaseguro, a_tipopol)
           --         RETURNING v_filtros;


--Filtro de Cliente
IF a_cod_cliente <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Usuario "||TRIM(a_cod_cliente);
	LET _tipo = sp_sis04(a_cod_cliente); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registro

		UPDATE temp_det
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE temp_det
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contratante IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF
--Filtro de Poliza
IF a_no_documento <> "*" and a_no_documento <> "" THEN
	LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);
	UPDATE temp_det
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND no_documento <> a_no_documento;
END IF
--Filtro por Agente
if a_codagente <> "*" then
	let v_filtros = trim(v_filtros) ||"Agente "||trim(a_codagente);
	let _tipo = sp_sis04(a_codagente); -- separa los valores del string

	if _tipo <> "E" then -- incluir los registros
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente not in(select codigo from tmp_codigos);
	else
		update temp_det
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_agente in(select codigo from tmp_codigos);
	end if
	drop table tmp_codigos;
end if
IF a_codvend <> "*" THEN   -- Aplica Filtro de Zona
	LET _tipo = sp_sis04(a_codvend); -- Separa los valores del String
	--LET v_filtros = TRIM(v_filtros) ||" Zona :"; --||TRIM(a_codvend);	

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE temp_det
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor NOT IN(SELECT codigo FROM tmp_codigos);
		   LET v_saber = "";		   
	ELSE
		UPDATE temp_det
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_vendedor IN(SELECT codigo FROM tmp_codigos);
		   LET v_saber = " Ex";		   
	END IF
	
	{FOREACH
		SELECT Distinct temp_det.nombre_vendedor,tmp_codigos.codigo
		  INTO _nombre_vendedor,v_codigo
		  FROM temp_det,tmp_codigos
		 WHERE temp_det.cod_vendedor = codigo
		 
		 LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(_nombre_vendedor) || (v_saber);
	END FOREACH}

	DROP TABLE tmp_codigos;
END IF
FOREACH WITH HOLD
	 SELECT cod_ramo,
			no_factura,
			no_documento,
			cod_contratante,
			estatus,
			forma_pago,
			cant_pagos,
			suma_asegurada,
			prima,
			comision,
			cod_agente,
			no_poliza,
			nueva_renov,
			cod_sucursal,
			no_endoso,
			cod_usuario,
			periodo,
			nombre_vendedor,
			prima_neta
	   INTO v_cod_ramo,
			v_nofactura,
			v_nodocumento,
			v_cod_contratante,
			v_estatus,
			v_forma_pago,
			v_cant_pagos,
			v_suma_asegurada,
			v_prima_suscrita,
			v_comision,
			v_cod_agente,
			v_nopoliza,
			v_nueva_renov,
			v_cod_sucursal,
			v_noendoso,
			_cod_usu,
			_periodo,
			_n_vendedor_gen,
			_prima_neta
	   FROM temp_det
	  WHERE seleccionado = 1
	  ORDER BY cod_ramo,no_factura
	 
	 SELECT nombre
	   INTO _nom_agente
	   FROM agtagent
	  WHERE cod_agente = v_cod_agente;
	  
	 SELECT nombre
	   INTO v_desc_ramo
	   FROM prdramo
	  WHERE cod_ramo = v_cod_ramo;

	 select user_added,
			fecha_impresion,
			date(ind_fecha_emi),
			estatus_poliza,
			cod_tipoprod,
			vigencia_inic,
			vigencia_final
	   into _user,
			_fecha_impresion,
			_fecha_emision,
			_estatus_poliza,
			_cod_tipoprod,
			_vig_ini,
			_vig_fin
	   from emipomae
	  where no_poliza = v_nopoliza;
	  
	select count(*)
	  into _cnt_emifafac
	  from emifafac
	 where no_poliza = v_nopoliza;
	 
	select nombre into _n_tipoprod from emitipro
    where cod_tipoprod = _cod_tipoprod;

	if _cnt_emifafac is null then
		let _cnt_emifafac = 0;
	end if
	if _cnt_emifafac = 0 THEN
		let _facultativo = 'NO';
	else
		let _facultativo = 'SI';
	end IF
	  
	 select descripcion
	   into	v_nomuser
	   from insuser
	  where usuario = _user;

	 SELECT trim(descripcion)
	   INTO v_sucursal
	   FROM insagen
	  WHERE codigo_agencia  = v_cod_sucursal
		AND codigo_compania = "001";

	 if v_noendoso <> '00000' then

		let _desc_endoso = "Endoso";
		select fecha_impresion,
			   fecha_emision
		  into _fecha_impresion,
			   _fecha_emision
		  from endedmae
		 where no_poliza = v_nopoliza
		   and no_endoso = v_noendoso;
	 else
		let _desc_endoso = "";
	 end if
	 if v_nueva_renov = 'R' then
		let _desc_nueva_renov = "Renovacion";
	 elif v_nueva_renov = 'N' then
		let _desc_nueva_renov = "Nueva";
	 end if

		let _cnt_pag = 0;
		let _monto_pen = 0.00;

		select monto_pen
		  into _monto_pen
		  from emiletra
		 where no_poliza = v_nopoliza
		   and no_letra = 1;
		
			if _monto_pen > 5.00 or _monto_pen < 0.00 or _monto_pen is null then
				let _pag_1_letra = "NO";
			else
				let _pag_1_letra = "SI";			
			end if 
				
			if _estatus_poliza = 1 then
			  let _estatus_nom2 = "VIGENTE";
			elif _estatus_poliza = 2 then
			  let _estatus_nom2 = "CANCELADA";
			elif _estatus_poliza = 3 then
			  let _estatus_nom2 = "VENCIDA";
			elif _estatus_poliza = 4 then
			  let _estatus_nom2 = "ANULADA";
			else
			  let _estatus_nom2 = "NO APLICA";
			end if		
			
	 SELECT nombre
	   INTO v_desc_nombre
	   FROM cliclien
	  WHERE cod_cliente = v_cod_contratante;
	  
	  LET v_nodocumento_xls = trim(v_nodocumento);	

	  RETURN v_cod_ramo,
	         v_desc_ramo,
			 v_nofactura,
			 v_nodocumento_xls,
			 _estatus_nom2,
			 v_desc_nombre,
			 v_suma_asegurada,
			 v_prima_suscrita,
			 _prima_neta,
			 v_comision,
			 _pag_1_letra,
			 v_forma_pago,
			 v_cant_pagos,
			 v_descr_cia,
			 v_filtros,
			 v_estatus,
			 v_nomuser,
			 _desc_endoso,
			 v_sucursal,
			 _desc_nueva_renov,
			 _fecha_impresion,
			 _fecha_emision,
			 _nom_agente,
			 _cod_usu,
			 _n_vendedor_gen,
			 _facultativo,
			 _n_tipoprod,
			 _periodo,
			 _vig_ini,
			 _vig_fin
			WITH RESUME;
END FOREACH
DROP TABLE temp_det;
END
END PROCEDURE;