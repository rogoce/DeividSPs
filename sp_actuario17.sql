
DROP procedure sp_actuario17;

 CREATE procedure "informix".sp_actuario17()
	RETURNING char(18),
			  dec(16,2),
			  dec(16,2),
			  date;

 BEGIN

    DEFINE v_no_poliza                   CHAR(10);
    DEFINE v_no_documento                CHAR(20);
    DEFINE v_vigencia_inic,v_vigencia_final,v_fecha_cancel   DATE;
    DEFINE v_contratante,v_placa              CHAR(10);
    DEFINE v_cod_ramo                         CHAR(3);
    DEFINE _pagado_bruto                   DECIMAL(16,2);
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
	define _filtros                           varchar(255);
	define _numrecla						  char(18);
	define _reserva_actual					  dec(16,2);
	define _fecha_reclamo                     date;
	define _no_reclamo                        char(10);

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


--*********************************
-- Siniestros Pagados Salud
--*********************************
call sp_rec01('001', '001', '2014-01', '2014-12','*','*','018;') returning _filtros;

foreach
 select numrecla,
        pagado_bruto,
		no_reclamo
   into _numrecla,
        _pagado_bruto,
		_no_reclamo
   from tmp_sinis
  where seleccionado = 1
    and periodo >= "2014-01"
	and periodo <= "2014-12"

   select reserva_actual,
          fecha_reclamo
     into _reserva_actual,
	      _fecha_reclamo
     from recrcmae
    where no_reclamo = _no_reclamo;


  return _numrecla,_pagado_bruto,_reserva_actual,_fecha_reclamo with resume;

end foreach

drop table tmp_sinis;



END
END PROCEDURE;
