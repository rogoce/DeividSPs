
DROP PROCEDURE sp_che82bk;

CREATE PROCEDURE sp_che82bk() RETURNING INTEGER; 

DEFINE _comision 		DEC(16,2);
DEFINE _no_requis		CHAR(10);
DEFINE _cuenta      	CHAR(25);
define _renglon			smallint;
define _enlace_cta      char(20);

foreach
	select no_requis,
	       monto
	  into _no_requis,
	       _comision
	  from chqchmae
	 where origen_cheque   = 8
	   and tipo_requis     = "A"
	   and fecha_impresion = "11/06/2008"

		-- Registros Contables del Banco
		SELECT MAX(renglon)
		  INTO _renglon	
		  FROM chqchcta
		 WHERE no_requis = _no_requis;

		IF _renglon IS NULL THEN
			LET _renglon = 0;
		END IF

		LET _renglon = _renglon + 1;

		LET _enlace_cta = 'BACHEQL'; -- Chequera Bancos Locales
		LET _cuenta = sp_sis15(_enlace_cta, '02', '001', '001');

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito
		)
		VALUES(
		_no_requis,
		_renglon,
		_cuenta,
		0,
		_comision
		);

end foreach

RETURN 0;

END PROCEDURE;