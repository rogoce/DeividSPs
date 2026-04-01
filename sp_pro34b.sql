-- Modificado: 16/08/2001 - Marquelda Valdelamar (inclusion de filtro de cliente)
--			   06/09/2001                         inclusion de filtro de poliza
-- Modificado: 15/09/2010 - Roman Gordon (inclusion de columnas y filtro por fecha)

drop procedure sp_pro34b;
create procedure "informix".sp_pro34b(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_codsucursal	char(255)	default "*",
a_codgrupo		char(255)	default "*",
a_codagente		char(255)	default "*",
a_codusuario	char(255) default "*",
a_codramo		char(255)	default "*",
a_reaseguro		char(255)	default "*",
a_tipopol		char(1),
a_cod_cliente	char(255)	default "*",
a_no_documento	char(255)	default "*",
a_fecha1		date,
a_fecha2		date,
a_por_fecha		smallint	default 0)
returning	char(3),
			char(50),
			char(10),
			char(20),
			char(50),
			dec(16,2),
			dec(16,2),
			dec(9,2),
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
			varchar(50);

--------------------------------------------
---  DETALLE DE FACTURACION POR RAMO     ---
---  Yinia M. Zamora - octubre 2000 - YMZM
---  Ref. Power Builder - d_sp_pro34b
--------------------------------------------

   BEGIN
      DEFINE v_nopoliza,v_nofactura          CHAR(10);
      DEFINE v_nodocumento                   CHAR(20);
      DEFINE v_noendoso                      CHAR(5);
      DEFINE v_cod_sucursal,v_cod_ramo,v_cod_tipoprod  CHAR(03);
      DEFINE v_cod_usuario                   CHAR(8);
      DEFINE v_cod_contratante               CHAR(10);
      DEFINE v_prima_suscrita,v_suma_asegurada   dec(16,2);
      DEFINE v_comision                      dec(9,2);
      DEFINE v_desc_nombre                   CHAR(35);
      DEFINE v_desc_ramo                     CHAR(50);
      DEFINE v_filtros                       CHAR(255);
      DEFINE _tipo                           CHAR(1);
      DEFINE v_estatus                       SMALLINT;
      DEFINE v_forma_pago                    CHAR(3);
      DEFINE v_cant_pagos                    SMALLINT;
      DEFINE v_descr_cia,v_desc_agente       CHAR(50);
	  define v_cod_agente					 char(5);
	  define v_nueva_renov					 char(1);
	  define v_nomuser						 varchar(50);
	  define _user							 varchar(15);
	  define _desc_endoso					 char(6);
	  define v_sucursal						 char(50);
	  define _desc_nueva_renov				 char(12);
	  define _fecha_impresion				 date;
	  define _fecha_emision					 date;
	  define _nom_agente					 varchar(50);

	  --define v_

      SET ISOLATION TO DIRTY READ;

      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cant_pagos      = 0;
      LET v_estatus         = NULL;
      LET v_comision        = 0;
      LET v_cod_contratante = NULL;

      LET v_descr_cia = sp_sis01(a_compania);

	  IF a_por_fecha=1 THEN
		  CALL sp_pro193(a_compania,a_agencia,a_fecha1,
		                 a_fecha2,a_codsucursal,a_codgrupo,a_codagente,
		                 a_codusuario,a_codramo,a_reaseguro, a_tipopol)
		                 RETURNING v_filtros;
	  ELSE
	      CALL sp_pro34(a_compania,a_agencia,a_periodo1,
	                    a_periodo2,a_codsucursal,a_codgrupo,a_codagente,
	                    a_codusuario,a_codramo,a_reaseguro, a_tipopol)
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

         IF _tipo <> "E" THEN -- Incluir los Registroo

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

      FOREACH WITH HOLD
         SELECT x.cod_ramo,
         		x.no_factura,
         		x.no_documento,
         		x.cod_contratante,
                x.estatus,
                x.forma_pago,
                x.cant_pagos,
                x.suma_asegurada,
                x.prima,
                x.comision,
				x.cod_agente,
				x.no_poliza,
				x.nueva_renov,
				x.cod_sucursal,
				x.no_endoso
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
				v_noendoso
           FROM temp_det x
          WHERE x.seleccionado = 1
          ORDER BY x.cod_ramo,x.no_factura

         
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
				date(ind_fecha_emi)
		   into _user,
				_fecha_impresion,
				_fecha_emision
		   from emipomae
		  where no_poliza = v_nopoliza;

		 select descripcion
		   into	v_nomuser
		   from insuser
		  where usuario = _user;

		 SELECT trim(descripcion)
		   INTO v_sucursal
		   FROM insagen
		  WHERE codigo_agencia  = v_cod_sucursal
		    AND codigo_compania = "001";

		 if v_noendoso<> '00000' then

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
		

      {   SELECT nombre
           INTO v_desc_agente
           FROM agtagent
          WHERE cod_agente = v_cod_agente; }

         SELECT nombre
           INTO v_desc_nombre
           FROM cliclien
          WHERE cod_cliente = v_cod_contratante;

         RETURN v_cod_ramo,v_desc_ramo,v_nofactura,v_nodocumento,
                v_desc_nombre,v_suma_asegurada,v_prima_suscrita,
                v_comision,v_forma_pago,v_cant_pagos,v_descr_cia,
                v_filtros,v_estatus,v_nomuser,_desc_endoso,v_sucursal,
                _desc_nueva_renov,_fecha_impresion,_fecha_emision,_nom_agente WITH RESUME;
                --,v_cod_agente,v_desc_agente  WITH RESUME;

      END FOREACH

   DROP TABLE temp_det;
   END
END PROCEDURE;