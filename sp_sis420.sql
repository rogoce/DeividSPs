
--execute procedure sp_pro73cc('001','001')

DROP procedure sp_sis420;

 CREATE procedure "informix".sp_sis420(a_compania CHAR(3),a_agencia CHAR(3))
   RETURNING integer,
             integer,
			 integer,
             integer,
			 integer;
			 
   			 
   			 

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

	define _cod_subramo       char(3);
	define _cod_contratante   char(10);
	define _cnt_007			  integer;
	define _cnt_008			  integer;
	define _cnt_009			  integer;

    define _p00318			  integer;
	define _p00312			  integer;
	define _celular           char(10);


	SET ISOLATION TO DIRTY READ;



let _cnt_007 = 0;
let _cnt_008 = 0;
let _cnt_009 = 0;

foreach

	   SELECT no_documento
	     into v_no_documento
         FROM emipomae
        WHERE actualizado = 1
          and cod_ramo = '018'
		  and cod_subramo in('007','008','009')
		  and estatus_poliza = 1
          group by no_documento
          order by no_documento

		let v_no_poliza = sp_sis21(v_no_documento);

        select cod_contratante,cod_subramo
		  into _cod_contratante,_cod_subramo
		  from emipomae
		 where no_poliza = v_no_poliza;

        let _celular = null;

        select celular
		  into _celular
		  from cliclien
		 where cod_cliente = _cod_contratante;

        if _celular is not null then

			if _cod_subramo = '007' then
				let _cnt_007 = _cnt_007 + 1;  --Pma plus individual
			elif _cod_subramo = '008' then	  
				let _cnt_008 = _cnt_008 + 1;  --Pma individual
			elif _cod_subramo = '009' then				
				let _cnt_009 = _cnt_009 + 1;  --Global individual
			end if

        end if



end foreach

let _p00318 = 0;
let _p00312 = 0;


foreach

	   SELECT no_documento
	     into v_no_documento
         FROM emipomae
        WHERE actualizado = 1
          and cod_ramo = '002'
		  and estatus_poliza = 1
     group by no_documento
     order by no_documento

		let v_no_poliza = sp_sis21(v_no_documento);

        select cod_contratante
		  into _cod_contratante
		  from emipomae
		 where no_poliza = v_no_poliza;

	  foreach

		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = v_no_poliza

		if _cod_producto = '00312' then	 --Producto completa
		    
			--let _cnt_007 = _cnt_007 + 1;
	        let _celular = null;

	        select celular
			  into _celular
			  from cliclien
			 where cod_cliente = _cod_contratante;

	        if _celular is not null then

				let _p00312 = _p00312 + 1;

			end if

		end if

		if _cod_producto = '00318' then	  --Producto Usadito

			--let _cnt_008 = _cnt_008 + 1;

	        let _celular = null;

	        select celular
			  into _celular
			  from cliclien
			 where cod_cliente = _cod_contratante;

	        if _celular is not null then

				let _p00318 = _p00318 + 1;

			end if

		end if
        
		exit foreach;

	  end foreach


end foreach

return _cnt_007,_cnt_008,_cnt_009,_p00318,_p00312;

END

END PROCEDURE;
