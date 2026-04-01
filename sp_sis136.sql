--Procedimiento para actualizar en emipomae las formas de pago
	-- Nuevas validaciones a la forma de pago solicitas por
	-- Carlos Berrocal el 30 - Sep - 2010

--084 = Coaseguro Minoritario
--089 = Fianzas de cualtipo de produccion = 089 excepto Tarjeta de credito y ACH
--085 = Fronting
--070 = Reaseguro Asumido


DROP PROCEDURE sp_sis136;

CREATE PROCEDURE "informix".sp_sis136()

RETURNING INTEGER;

DEFINE _no_documento    CHAR(20);
define _no_poliza       CHAR(10);
define _ramo_sis        smallint;
define _fronting        smallint;
DEFINE _error     	    SMALLINT;
DEFINE _cod_formapag    CHAR(3);
DEFINE _tipo_forma      SMALLINT; 
DEFINE _cod_tipoprod    CHAR(3);
DEFINE _tipo_produccion SMALLINT;
DEFINE _cod_ramo        CHAR(3);


SET ISOLATION TO DIRTY READ;

let _fronting  = 0;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

foreach

	select no_documento
	  into _no_documento
	  from emipomae
	 where actualizado = 1
	 group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	SELECT cod_formapag,
		   cod_tipoprod,
		   cod_ramo
	  INTO _cod_formapag,
		   _cod_tipoprod,
		   _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_forma
	  INTO _tipo_forma
	  FROM cobforpa
	 WHERE cod_formapag = _cod_formapag;

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_tipoprod = "002" then -- Coaseguro Minoritario

		let _cod_formapag = "084";

	elif _cod_tipoprod = "002" then -- Reaseguro Asumido

		let _cod_formapag = "070";

	end if

	if _tipo_forma = 2 or _tipo_forma = 4 then	--2=visa,4=ach
	else
		if _ramo_sis = 3 then --Fianzas
			let _cod_formapag = "089";
		end if
	end if

	let _fronting = sp_sis135(_no_poliza);

	if _fronting = 1 then --es fronting
		let _cod_formapag = "085";
	end if

	if _cod_formapag in("084","070","089","085") then

		UPDATE emipomae
		   SET cod_formapag = _cod_formapag
		 WHERE no_documento = _no_documento;

	end if


end foreach

END
RETURN 0;
END PROCEDURE;
