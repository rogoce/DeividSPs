-- Reporte Emireimp
-- Creado    : 14/04/2011 - Autor: Henry Giron
DROP PROCEDURE sp_pro349;
CREATE PROCEDURE "informix".sp_pro349(a_desde date,a_hasta date,a_sucursal char(255))
returning char(20),		 -- no_documento,
		  char(10),      -- no_poliza,
		  date,			 -- fecha_impresion,
		  char(8),		 -- user_imprimio,
		  char(10),		 -- no_factura
		  CHAR(255);     -- filtros


define _no_documento	char(20);
define _no_poliza   	char(10);
define _fecha_impresion date;
define _user_imprimio	char(8);
define _no_factura      char(10);
define _sucursal        char(3);
define _seleccion       smallint;
DEFINE _tipo            char(01);
DEFINE v_filtros        char(255);

Create Temp Table tmp_pro349(
	 no_documento	char(20),
     no_poliza   	char(10),
	 fecha_impresion date,
	 user_imprimio	char(8),
	 no_factura      char(10),
	 sucursal        char(3),
	 seleccion       smallint
	 ) With No Log;

SET ISOLATION TO DIRTY READ;

let _no_poliza  = null;
let _no_factura = null;
LET v_filtros   = "";

foreach
  SELECT no_documento,
         no_poliza,
         fecha_impresion,
         user_imprimio
    into _no_documento,
    	 _no_poliza,
    	 _fecha_impresion,
    	 _user_imprimio
    FROM emireimp
   WHERE ( fecha_impresion >= a_desde ) AND
         ( fecha_impresion <= a_hasta )

		select no_factura, sucursal_origen
	      into _no_factura, _sucursal
		  from emipomae
		 where no_poliza   = _no_poliza
		   and actualizado = 1 ;

   Insert into tmp_pro349(
			 no_documento,
			 no_poliza,
			 fecha_impresion,
			 user_imprimio,
			 no_factura,
			 sucursal,
			 seleccion
			 )
   values (	_no_documento,
			_no_poliza,
			_fecha_impresion,
			_user_imprimio,
			_no_factura,
			_sucursal,
			1
			);

end foreach

LET _tipo = "";
--Filtro por Sucursal
IF a_sucursal <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Sucursal "||TRIM(a_sucursal);
	LET _tipo = sp_sis04(a_sucursal); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
	   UPDATE tmp_pro349
	      SET seleccion = 0
	    WHERE seleccion = 1
	      AND sucursal NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	   UPDATE tmp_pro349
	      SET seleccion = 0
	    WHERE seleccion = 1
	      AND sucursal IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF


foreach
  SELECT no_documento,
		 no_poliza,
		 fecha_impresion,
		 user_imprimio,
		 no_factura,
		 sucursal
    into _no_documento,
		 _no_poliza,
		 _fecha_impresion,
		 _user_imprimio,
    	 _no_factura,
    	 _sucursal
    FROM tmp_pro349
   WHERE seleccion = 1

   return _no_documento,
		  _no_poliza,
		  _fecha_impresion,
          _user_imprimio,
          _no_factura,
          v_filtros
          with resume;

end foreach
	DROP TABLE tmp_pro349;


END PROCEDURE
                  

   