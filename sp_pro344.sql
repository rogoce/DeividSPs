-- Proyecto de Evaluacion de personas
-- Creado    : 17/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro344;
CREATE PROCEDURE sp_pro344()
returning char(3),		 --_cod_ramo
		  varchar(50),	 --_n_ramo
		  char(3),		 --_cod_subramo
		  varchar(50),	 --_n_subramo
		  char(10),      --_cod_contratante
		  varchar(100),	 --_n_contratante
		  date,			 --_vigencia_inic,   		  
		  date,			 --_vigencia_final,   		  
		  varchar(50),	 --_n_corredor
		  char(10),		 --_no_poliza
		  char(8),		 --_user_added
		  char(10),      --_no_evaluacion
		  char(3);

define _no_poliza	    char(10);	 		   
define _cod_contratante char(10);	 		   
define _user_added   	char(8);			   
define _vigencia_inic	date;				   
define _vigencia_final	date;				   
define _cod_agente  	char(5);
define _saldo_porc      integer;
define _n_corredor      varchar(50);
define _n_contratante   varchar(100);
define _cod_ramo        char(3);
define _n_ramo          varchar(50);
define _cod_subramo     char(3);
define _n_subramo       varchar(50);
define _no_evaluacion   char(10);
define _cod_sucursal    char(3);

SET ISOLATION TO DIRTY READ;

let _no_evaluacion = null;

foreach

  SELECT no_poliza,   
         user_added,   
         cod_ramo,
         cod_subramo,   
         vigencia_inic,   
         vigencia_final,
		 cod_contratante,
		 sucursal_origen
	INTO _no_poliza,
		 _user_added,   
		 _cod_ramo,
		 _cod_subramo,
		 _vigencia_inic,   
		 _vigencia_final,   
		 _cod_contratante,
		 _cod_sucursal
    FROM emipomae  
   WHERE user_added  = 'EVALUACI'
     AND actualizado = 0

  SELECT no_evaluacion
	INTO _no_evaluacion
	FROM emievalu
   WHERE no_poliza  = _no_poliza;

  SELECT nombre
	INTO _n_contratante
	FROM cliclien
   WHERE cod_cliente = _cod_contratante;

  SELECT nombre
	INTO _n_ramo
	FROM prdramo
   WHERE cod_ramo = _cod_ramo;

  SELECT nombre
	INTO _n_subramo
	FROM prdsubra
   WHERE cod_ramo    = _cod_ramo
     AND cod_subramo = _cod_subramo;

  foreach

	select cod_agente
	  into _cod_agente
	  from emipoagt
	 where no_poliza = _no_poliza

	exit foreach;


  end foreach

  SELECT nombre
    INTO _n_corredor
    FROM agtagent
   WHERE cod_agente = _cod_agente;

   return _cod_ramo,
          _n_ramo,
		  _cod_subramo,
		  _n_subramo,
		  _cod_contratante,
		  _n_contratante,
		  _vigencia_inic,   
		  _vigencia_final,   
   		  _n_corredor,
   		  _no_poliza,
   		  _user_added,
		  _no_evaluacion,
		  _cod_sucursal
		  with resume;
end foreach

END PROCEDURE
