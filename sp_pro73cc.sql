

--DROP procedure sp_pro73cc;

 CREATE procedure "informix".sp_pro73cc(a_compania CHAR(3),a_agencia CHAR(3),a_fecha_desde date, a_fecha_hasta date)
   RETURNING CHAR(20),
             integer,
			 decimal(16,2),
             integer,  
			 decimal(16,2),
			 decimal(16,2),
			 decimal(16,2),
   			 DEC(16,2),	
   			 DEC(16,2),
			 char(50);

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
	define _cnt_menor		  integer;
	define _cnt_mayor		  integer;
 	define _suma_menor		  DECIMAL(16,2);
	define _suma_mayor		  DECIMAL(16,2);
	define _cnt               smallint;
	define _cod_grupo         char(10);
	define _n_grupo           char(50);
	define _periodo1          char(7);
	define _periodo2          char(7);

    LET v_descr_cia = sp_sis01(a_compania);
	LET v_prima_aseg = 0;
	SET ISOLATION TO DIRTY READ;

	let _cnt_menor	= 0;
	let	_cnt_mayor	= 0;
	let	_suma_menor	= 0;
	let	_suma_mayor	= 0;

CREATE TEMP TABLE tmp_prov(
	no_documento  CHAR(20),
	cnt_uni_menor integer       default 0,
	cnt_uni_mayor integer       default 0,
	suma_menor	  decimal(16,2) default 0,
	suma_mayor    decimal       default 0,
	inc_bruto     decimal(16,2) default 0,
	pagado_bruto  decimal(16,2)	default 0,
	grupo         char(50)
	) WITH NO LOG;
	

CREATE INDEX xie01_tmp_prov ON tmp_prov(no_documento);
let _periodo1 = sp_sis39(a_fecha_desde);
let _periodo2 = sp_sis39(a_fecha_hasta);

LET v_filtros = sp_rec01(
a_compania, 
a_agencia, 
_periodo1, 
_periodo2,
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
          and vigencia_inic between a_fecha_desde and a_fecha_hasta
          and cod_ramo = '016'
          group by no_documento
          order by no_documento

		let v_no_poliza = sp_sis21(v_no_documento);

       SELECT suma_asegurada,cod_grupo
         INTO _suma_asegurada,_cod_grupo
         FROM emipomae
        WHERE no_poliza = v_no_poliza;
        
		select nombre into _n_grupo from cligrupo
		 where cod_grupo = _cod_grupo;

	   let _cnt_menor  = 0;
	   let _cnt_mayor  = 0;
	   let _suma_mayor = 0;
	   let _suma_menor = 0;
       foreach
			select suma_asegurada
			  into _suma_menor
			  from emipouni
			 where no_poliza = v_no_poliza

			if _suma_menor >= 0 and _suma_menor <= 15000 then
				let _cnt_menor = 1;
				let _cnt_mayor = 0;
				let _suma_mayor = 0;
			elif _suma_menor > 15000 then
				let _cnt_menor = 0;
				let _cnt_mayor = 1;
				let _suma_mayor = _suma_menor;
				let _suma_menor = 0;
			end if

			select count(*)
			  into _cnt
			  from tmp_prov
			 where no_documento = v_no_documento;

			if _cnt = 0 then

				insert into tmp_prov
				(no_documento, 
				 cnt_uni_menor,
				 cnt_uni_mayor,
				 suma_menor,	 
				 suma_mayor,   
				 inc_bruto,    
				 pagado_bruto,
				 grupo)
				 values(
				 v_no_documento,
				 _cnt_menor,
				 _cnt_mayor,
				 _suma_menor,
				 _suma_mayor,
				 0,
				 0,
				 _n_grupo);
			else
				 update tmp_prov
				    set cnt_uni_menor = cnt_uni_menor + _cnt_menor,
						cnt_uni_mayor = cnt_uni_mayor + _cnt_mayor,
						suma_menor    = suma_menor    + _suma_menor,	
						suma_mayor    = suma_mayor    + _suma_mayor 
				  where no_documento = v_no_documento;
			end if
				  
       end foreach

	   foreach

			 SELECT sum(pagado_bruto), 		
				    sum(incurrido_bruto)	
			   INTO	v_pagado_bruto, 		
				    v_incurrido_bruto	
			   FROM tmp_sinis 
			  WHERE seleccionado = 1
				and no_poliza    = v_no_poliza
				and cod_ramo     = '016'

			 update tmp_prov
			    set inc_bruto    = v_incurrido_bruto,
					pagado_bruto = v_pagado_bruto
			  where no_documento = v_no_documento;


       end foreach

end foreach

foreach

	  select no_documento, 
			 cnt_uni_menor,
			 cnt_uni_mayor,
			 suma_menor,	
			 suma_mayor,   
			 inc_bruto,    
			 pagado_bruto,
			 grupo
		into v_no_documento,
			 _cnt_menor,
			 _cnt_mayor,
			 _suma_menor,
			 _suma_mayor,
			 v_incurrido_bruto,
			 v_pagado_bruto,
			 _n_grupo
		from tmp_prov
	   order by no_documento,suma_menor


	       RETURN v_no_documento,
				  _cnt_menor,
				  _suma_menor,
				  _cnt_mayor,
				  _suma_mayor,
				  _cnt_menor+_cnt_mayor,
				  _suma_menor+_suma_mayor,
				  v_incurrido_bruto, 
				  v_pagado_bruto,
				  _n_grupo
				  WITH RESUME;


end foreach

drop table tmp_sinis;
drop table tmp_prov;

END

END PROCEDURE;
