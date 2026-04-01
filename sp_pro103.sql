DROP PROCEDURE sp_pro103;

CREATE PROCEDURE "informix".sp_pro103(
		a_poliza        CHAR(10),
		a_endoso  		CHAR(5),
		a_unidad        CHAR(5)
        ) RETURNING  CHAR(81);


DEFINE _sucursal_origen  CHAR(3);
DEFINE _cod_grupo  		 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _cod_subramo,v_cod_ramo    	 CHAR(3);
DEFINE _no_documento     CHAR(20);
DEFINE _cod_contratante  CHAR(10);
DEFINE _no_poliza		 CHAR(10);
DEFINE v_desc_agente     CHAR(50);
DEFINE v_desc_subramo    CHAR(50);
DEFINE _cod_tipoprod     CHAR(3);
DEFINE _tipo_produccion  CHAR(1);
DEFINE v_descripcion     CHAR(255);
DEFINE _tipo		     CHAR(1);
DEFINE v_saber 			 CHAR(3);
DEFINE v_codigo			 CHAR(5);
DEFINE lblb_blob         byte;
DEFINE ls_archivo, ls_depurar, ls_nueva  CHAR(255);
DEFINE ll_inicio         INTEGER;
DEFINE ll_vez            INTEGER;
DEFINE i,j               INTEGER;
DEFINE ll_letras         INTEGER;

-- Tabla Temporal tmp_prod

CREATE TEMP TABLE tmp_blobuni(
		no_poliza	   	CHAR(10)  NOT NULL,
		no_endoso       CHAR(5)   NOT NULL,
		no_unidad       CHAR(5)   NOT NULL,
		renglon         SMALLINT,
		descripcion     CHAR(81)
		) WITH NO LOG;

--SET DEBUG FILE TO "sp_pro103.trc";
--trace on;

SET ISOLATION TO DIRTY READ;

			LET ll_inicio = 1;
			LET	ll_vez    = 1;
			LET	i		  = 1;
			LET	j         = 1;
			LET	ll_letras = 0;


			SELECT emipode2.descripcion
			  INTO lblb_blob
			  FROM emipode2
			 WHERE emipode2.no_poliza = a_poliza
			   AND emipode2.no_unidad = a_unidad;
	

--			If Len(lblb_blob) > 0 Then
			   LET ls_archivo = lblb_blob;
				If ls_archivo = "" Or ls_archivo = " " Then
					RETURN " ";
				End If

				For i = 1 to Len(ls_archivo)
					if asc(mid(ls_archivo,i,1)) = 13  then
						LET ls_depurar = ls_depurar + "|";
					else
						if asc(mid(ls_archivo,i,1)) = 10 then
							LET ls_depurar = ls_depurar + " ";
						else
							LET ls_depurar = ls_depurar + mid(ls_archivo,i,1);
						end if
					end if
				End For;
				LET ls_archivo = ls_depurar;
				For i = 1 To Len(ls_archivo)
					If ((ll_letras >= 70) And mid(ls_archivo, i, 1) = " ") OR (mid(ls_archivo, i, 1) = "|")  Then
						LET ls_nueva = mid(ls_archivo, ll_inicio, ll_letras);
						Insert Into tmp_blobuni
							Values(a_poliza, a_endoso, a_unidad, j, ls_nueva);
						LET j = j + 1;
						if  (mid(ls_archivo, i, 1) = "|")  then
							LET ll_inicio = i + 1;
							LET ll_letras = 0;
						else
							LET ll_inicio = i;
							LET ll_letras = 1;
						end if
						LET ll_vez = ll_vez + 1;
					Else
						LET ll_letras = ll_letras + 1;
					End If
				End For;
				LET ls_nueva = mid(ls_archivo, ll_inicio, ll_letras);
				Insert Into tmp_blobuni
					Values(a_poliza, a_endoso, a_unidad, j, ls_nueva);
				LET ls_depurar = NULL;
				LET ls_depurar = "";
  --			End If


FOREACH WITH HOLD
   SELECT descripcion
     INTO v_descripcion
	 FROM tmp_blobuni

   RETURN v_descripcion
     WITH RESUME;
END FOREACH

DROP TABLE tmp_blobuni;

END PROCEDURE;
