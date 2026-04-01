 DROP procedure sp_cobranza;

 CREATE procedure "informix".sp_cobranza()
   RETURNING char(10),char(20),dec(16,2),char(7),char(1);
 
--------------------------------------------
---  REPORTE ESPECIAL QUE SUMINISTRA INF. DE PRIMAS Y SINIESTROS PARA RAMO SALUD
---  Armando Moreno M.
--------------------------------------------

 BEGIN

    DEFINE v_no_poliza                   	  CHAR(10);
    DEFINE v_no_documento                	  CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_cancel   DATE;
    DEFINE v_contratante,v_placa              CHAR(10);
    DEFINE v_cod_ramo                         CHAR(3);
    DEFINE v_suma_asegurada                   DECIMAL(16,2);
    DEFINE v_descripcion                      CHAR(50);
    DEFINE v_no_unidad                        CHAR(5);
    DEFINE v_no_motor                         CHAR(30);
    DEFINE v_cod_marca                        CHAR(5);
    DEFINE v_cod_modelo                       CHAR(5);
    DEFINE v_ano_auto                         SMALLINT;
    DEFINE v_desc_nombre                      CHAR(100);
    DEFINE v_nom_modelo,v_nom_marca           CHAR(30);
    DEFINE v_descr_cia                        CHAR(50);
	DEFINE _cod_sucursal					  CHAR(3);
	DEFINE _cod_tipoveh						  CHAR(3);
	DEFINE _sucursal                          CHAR(30);
	DEFINE _cnt								  INTEGER;
	DEFINE _fecha_suscripcion                 DATE;
	DEFINE _cod_contratante					  CHAR(10);
	define _prima                             dec(16,2);
	define _cedula,_ced_dep	    			  char(30);
	define _sexo,_sexo_dep					  char(1);
	define _cod_parentesco					  char(3);
	define _n_parentesco					  char(50);
	define _fecha_aniversario,_fecha_ani      date;
	define _edad_cte,_edad                    integer;
	define _cod_cte                           char(10);
	define _cod_producto                      char(5);
	define _n_producto                        char(50);
	define _fecha_ult_p                       date;
	define _cod_subramo                       char(3);
	define _n_subramo                         char(50);
	define _cod_asegurado                     char(10);
	define _estatus                           smallint;
	define _estatus_char                      char(9);
	define _prima_pagada                      dec(16,2);
	define _fecha_efectiva                    date;
	define _fecha_ani_ase                     date;
	define _ced_ase                           char(30);
	define _sexo_ase                          char(1);
	define _no_factura                        char(10);
	define _periodo                           char(7);
	define _fecha_ani_aseg,_fecha_efectiva2   date;
	define _prima_depen						  dec(16,2);
	define _valor						      char(10);
	define _cod_formapag					  char(3);
	define _no_documento                      char(20);
	define _prima_cobrada					  dec(16,2);
	define _no_poliza						  char(10);
	define _tipo_forma                        smallint;
	define _saber                             char(1);


SET ISOLATION TO DIRTY READ; 

let _prima_pagada = 0;
let _ced_dep = '';
let _sexo_dep = '';
let _fecha_ani = '01/01/2010';
let _n_parentesco = '';
let _prima_cobrada = 0;


FOREACH WITH HOLD


	   select periodo,
	          no_documento,
			  prima_cobrada
		 into _periodo,
		      _no_documento,
			  _prima_cobrada
		 from chqbonoc
		where cod_agente = '00081'

      let _no_poliza = sp_sis21(_no_documento);

       SELECT cod_formapag
         INTO _cod_formapag
         FROM emipomae
        WHERE no_poliza = _no_poliza;

	  select count(*)
	    into _cnt
		from chqboni
	   where cod_agente   = '00081'
		 and periodo      = '2011-06'
	     and no_documento = _no_documento;


	  if _cnt = 0 then
         let _saber = 'N';
	  else
         let _saber = '';		  
	  end if

	--Buscar forma de pago
	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	if _tipo_forma in(2,3,4) then
		let _valor = "ELECTR.";
	ELSE
		let _valor = "OTRA";		
	end if

	return _valor,_no_documento,_prima_cobrada,_periodo,_saber with resume;


END FOREACH

END
END PROCEDURE;
