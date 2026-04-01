 DROP procedure sp_pro73b;

 CREATE procedure "informix".sp_pro73b(a_compania CHAR(3),a_agencia CHAR(3))
   RETURNING CHAR(20),  
   			 decimal(16,2),	
   			 CHAR(18),	
   			 DEC(16,2),	
   			 DEC(16,2);	


BEGIN

    DEFINE v_no_poliza        CHAR(10);
    DEFINE v_cod_aseg         CHAR(10);
    DEFINE v_no_documento     CHAR(20);
    DEFINE v_contratante      CHAR(10);
    DEFINE v_cod_ramo      	  CHAR(3);
    DEFINE v_descripcion   	  CHAR(50);
    DEFINE v_no_unidad        CHAR(5);
    DEFINE v_desc_nombre      CHAR(100);
    DEFINE v_desc_asegurado   CHAR(100);
    DEFINE v_descr_cia        CHAR(50);
    DEFINE _suma_asegurada    DECIMAL(16,2);
    DEFINE _fecha_aniversario DATE;
    DEFINE _edad,_cant		  SMALLINT;
	define _cedula			  char(30);
	DEFINE v_incurrido_bruto  DECIMAL(16,2);
	DEFINE v_pagado_bruto     DECIMAL(16,2);
	DEFINE v_prima_aseg       DECIMAL(16,2);
	DEFINE _edad_tot          INTEGER;
	define _cod_producto      char(5);
	define v_doc_reclamo      char(18);
	define v_filtros          varchar(255);

    LET v_descr_cia = sp_sis01(a_compania);
	LET v_prima_aseg = 0;
	SET ISOLATION TO DIRTY READ; 
	

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
'2014-01', 
'2014-11',
'*', 
'*', 
'016;', 
'*', 
'*', 
'*', 
'*',
'*'
);

foreach

	   SELECT no_documento
	     into v_no_documento
         FROM emipomae
        WHERE actualizado = 1
          and vigencia_inic between '01/01/2014' and '30/11/2014'
          and cod_ramo = '016'
          group by no_documento
          order by no_documento

		let v_no_poliza = sp_sis21(v_no_documento);

       SELECT suma_asegurada
         INTO _suma_asegurada
         FROM emipomae
        WHERE no_poliza = v_no_poliza;


	   foreach

			 SELECT sum(pagado_bruto), 		
				    sum(incurrido_bruto),	
					numrecla
			   INTO	v_pagado_bruto, 		
				    v_incurrido_bruto,	
					v_doc_reclamo
			   FROM tmp_sinis 
			  WHERE seleccionado = 1
				and no_poliza    = v_no_poliza
				and cod_ramo     = '016'
		   group by numrecla


	       RETURN v_no_documento,
	         	  _suma_asegurada,
				  v_doc_reclamo,
				  v_incurrido_bruto, 
				  v_pagado_bruto
				  WITH RESUME;

       end foreach

end foreach

drop table tmp_sinis;

END

END PROCEDURE;
