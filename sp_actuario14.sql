--reserva matematica 01/02/2010
 DROP procedure sp_actuario14;

 CREATE procedure "informix".sp_actuario14()
	RETURNING char(20),
			  date,
			  char(12),	   
			  date,	   
			  integer, 
			  char(1), 
			  char(50),
			  integer, 
			  dec(16,2),
			  date,	   
			  date,
			  char(10),
			  char(1),
			  dec(16,2),
			  dec(16,2),
			  date,
			  char(1);
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
	define _fumador							  char(1);
	define _fuma                              smallint;


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
let _fumador = "";
let _fuma    = 0;

FOREACH WITH HOLD

       SELECT no_documento
         INTO v_no_documento
         FROM emipomae
        WHERE cod_ramo    = "019"
		  AND actualizado = 1
		GROUP BY no_documento

	  -- let v_no_poliza = sp_sis21(v_no_documento);

	  	FOREACH
		 SELECT	no_poliza
		   INTO	v_no_poliza
		   FROM	emipomae
		  WHERE no_documento       = v_no_documento
			AND actualizado        = 1
		  ORDER BY vigencia_final desc
			EXIT FOREACH;
		END FOREACH


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

	   let _prima = 0;
	   	
       FOREACH
        
          SELECT no_unidad,
          		 suma_asegurada,
				 cod_producto,
				 cod_asegurado,
				 vigencia_inic,
				 prima
            INTO v_no_unidad,
            	 v_suma_asegurada,
				 _cod_producto,
				 _cod_asegurado,
				 _fecha_efectiva,
				 _prima
            FROM emipouni
           WHERE no_poliza = v_no_poliza

		  { if _cod_producto = '00154' then --vida termino
		   else
			continue foreach;
		   end if }

		  { if _cod_producto in('00726','00727','00728') then --vida confiable edad 70,85,99
		   else
			continue foreach;
		   end if  }

		   select count(*)
		     into _cnt
			 from emipocob
			where no_poliza     = v_no_poliza
			  and cod_cobertura = "01009";

		   if _cnt > 0 then

			   select prima_neta
			     into _prima_neta
				 from emipocob
				where no_poliza     = v_no_poliza
				  and cod_cobertura = "01009";

				let _tiene_cob = '*';

		   else
				let _prima_neta = 0;
				let _tiene_cob = '';
		   end if

	       SELECT fecha_aniversario,
		          cedula,
				  sexo,
				  fumador
	         INTO _fecha_ani,
			      _ced_dep,
				  _sexo_dep,
				  _fuma
	         FROM cliclien
	        WHERE cod_cliente = _cod_asegurado;

			select nombre
			  into _n_producto
			  from prdprod
			 where cod_producto = _cod_producto;

		   if _fecha_ani is not null then 
			   let _edad = sp_sis78(_fecha_ani,today);
		   else
		       let _edad = 0;
		   end if

		   if _fuma = 0 then
				let _fumador = "N";
		   else
				let _fumador = "S";
		   end if

		   return v_no_documento,
		          _fecha_suscripcion,
				  _estatus_char,
				  _fecha_ani,
				  _edad,
				  _sexo_dep,
				  _n_producto,
				  _no_pagos,
			      v_suma_asegurada,
			      v_vigencia_inic,
			      v_vigencia_final,
				  _cod_asegurado,
				  _tiene_cob,
				  _prima_neta,
				  _prima_bruta,
				  _vigencia_fin_pol,
				  _fumador
		   with resume;
		   	
       END FOREACH
        
END FOREACH

END
END PROCEDURE;
