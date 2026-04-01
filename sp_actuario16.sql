--reserva matematica 01/02/2010
DROP procedure sp_actuario16;

 CREATE procedure "informix".sp_actuario16()
	RETURNING char(20),
			  char(12),
			  char(1),
			  date,
			  date,
			  dec(16,2),
			  char(10);

 BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_no_documento                CHAR(20);
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
	define _no_pagos                          smallint;
	define _tiene_cob                         char(1);
	define _prima_neta   					  dec(16,2);
	define _prima_bruta  					  dec(16,2);
	define _vigencia_fin_pol                  date;
	define _no_pol_int                        integer;
	define _estatus_termino                   char(1);
	define _saldo                             dec(16,2);

SET ISOLATION TO DIRTY READ; 

let _prima_pagada = 0;
let _ced_dep      = '';
let _sexo_dep     = '';
let _fecha_ani    = '01/01/2007';
let _n_parentesco = '';
let _no_pagos     = 0;
let _prima_neta   = 0;
let	_prima_bruta  = 0;
let _tiene_cob    = 0;
let _estatus_termino = '';
let _saldo = 0;
let _no_factura   = "";

{CREATE TEMP TABLE te_pol
 (no_poliza      	integer)
  WITH NO LOG;}


FOREACH WITH HOLD

       SELECT no_documento
         INTO v_no_documento
         FROM emipomae
        WHERE cod_ramo     = "019"
		  AND actualizado  = 1
		GROUP BY no_documento

	   foreach
		 SELECT	no_poliza
		   INTO	v_no_poliza
		   FROM	emipomae
		  WHERE no_documento = v_no_documento
		  order by no_poliza - 0 desc
		 exit foreach;
	   end foreach

       SELECT no_poliza,
       		  no_documento,
       		  vigencia_inic,
              vigencia_final,
              fecha_cancelacion,
			  cod_sucursal,
			  fecha_suscripcion,
			  cod_contratante,
			  cod_subramo,
			  estatus_poliza,
			  no_pagos,
			  prima_neta,
			  prima_bruta,
			  vigencia_fin_pol
         INTO v_no_poliza,
         	  v_no_documento,
         	  v_vigencia_inic,
              v_vigencia_final,
              v_fecha_cancel,
			  _cod_sucursal,
			  _fecha_suscripcion,
			  _cod_contratante,
			  _cod_subramo,
			  _estatus,
			  _no_pagos,
			  _prima_neta,
			  _prima_bruta,
			  _vigencia_fin_pol
         FROM emipomae
        WHERE no_poliza	  = v_no_poliza
          AND cod_ramo    = "019"
		  AND actualizado = 1;

		let _estatus_char = '';

		if _estatus = 1 then
			let _estatus_char = 'VIGENTE';
		elif _estatus = 2 then
			let _estatus_char = 'CANCELADA';
		elif _estatus = 3 then
			let _estatus_char = 'VENCIDA';
		else
			let _estatus_char = '*';
		end if

		if _estatus = 3 then
		else
			continue foreach;
		end if

	   let _prima = 0;
	   	
	   if _estatus = 3 and (v_vigencia_final = _vigencia_fin_pol) then
			let _estatus_termino = '*';
	   else
			let _estatus_termino = '';
	   end if

	   let _saldo = sp_cob115b('001','001',v_no_documento,'');

	   select count(*)
	     into _cnt
	     from endedmae
	    where no_documento = v_no_documento
	      and cod_endomov = '002'
		  and actualizado = 1;

	   if _cnt > 0 then

		   foreach
		   
		   	 select no_factura
			   into _no_factura
			   from endedmae
			  where no_documento = v_no_documento
			    and cod_endomov = '002'
				and actualizado = 1

		   	 exit foreach;

		   end foreach
	   else
			let _no_factura = "";
	   end if

		   return v_no_documento,
				  _estatus_char,
				  _estatus_termino,
				  v_vigencia_inic,
				  _vigencia_fin_pol,
				  _saldo,
				  _no_factura
		   with resume;
       
END FOREACH

END
END PROCEDURE;
