
-- Creado    : 31/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pais;

CREATE PROCEDURE "informix".sp_pais()
returning smallint;


define _nombre		  varchar(35);	
define _gentilicio	  varchar(35);
define _no_tranrec_char      char(3);
define _no_tranrec_int integer;
define _code_pais  char(3);

SET ISOLATION TO DIRTY READ;

{create temp table tmp_eval(
no_eval			char(10),
renglon			smallint,
no_recibo		char(10),
tipo_mov		char(1),
doc_remesa		char(30),
recibi_de		char(50),
tipo_pago		smallint,
tipo_tarjeta	smallint,
importe			dec(16,2)
) with no log; }


--SET DEBUG FILE TO "sp_pro206.trc";
--trace on;

SET LOCK MODE TO WAIT;

BEGIN


{foreach					  

	SELECT nombre,
		   gentilicio
	  INTO _nombre,
		   _gentilicio
	  FROM pais
	 WHERE codigo not in(157,51,15)


SELECT valor_parametro
  INTO _no_tranrec_int
  FROM parcont
 WHERE cod_compania    = '001'
   AND aplicacion      = 'COB'
   AND version         = '02'
   AND cod_parametro   = 'par_genpais';



	LET _no_tranrec_int    = _no_tranrec_int + 1;

	UPDATE parcont
	   SET valor_parametro = _no_tranrec_int
     WHERE cod_compania    = '001'
	   AND aplicacion      = 'COB'
	   AND version         = '02'
	   AND cod_parametro   = 'par_genpais';


-- Numero de Transaccion

LET _no_tranrec_char  = '000';

IF _no_tranrec_int > 99  THEN
	LET _no_tranrec_char[1,3] = _no_tranrec_int;
ELIF _no_tranrec_int > 9  THEN
	LET _no_tranrec_char[2,3] = _no_tranrec_int;
ELSE
	LET _no_tranrec_char[3,3] = _no_tranrec_int;
END IF


	 let _nombre     = upper(_nombre);
	 let _gentilicio = upper(_gentilicio);


	 INSERT INTO genpais(
	 code_pais,
	 nombre,
	 gentilicio,
	 abrv_corta,
	 abrv_larga
	 )
	 VALUES(
	 _no_tranrec_char,
	 _nombre,
	 _gentilicio,
	 _nombre[1,2],
	 _nombre[1,3]
	 );

end foreach	}

foreach
	select nombre,
	       gentilicio,
		   code_pais
	  into _nombre,
	       _gentilicio,
		   _code_pais
	  from genpais

	  let _nombre     = trim(_nombre);	
	  let _gentilicio = trim(_gentilicio);

	  update genpais
	     set nombre     = _nombre,
		     gentilicio = _gentilicio
	   where code_pais  = _code_pais;

end foreach

return 0;

END
END PROCEDURE
