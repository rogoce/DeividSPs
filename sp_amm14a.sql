DROP procedure sp_amm14a;
--cuentas de Ach mal creadas
CREATE procedure "informix".sp_amm14a()

RETURNING   varchar(17),
            CHAR(100),
            CHAR(10),
            integer,
            char(1);

    DEFINE _no_cuenta      varchar(17);
    DEFINE _cedula		   CHAR(30);
    DEFINE _cod_pagador    CHAR(10);
    DEFINE v_documento     CHAR(20);
	DEFINE _vigencia_final DATE;
	DEFINE _nombre_pagador CHAR(100);
	DEFINE _cant 		   integer;	

SET ISOLATION TO DIRTY READ;

let _cant = 0;

begin work;
begin
FOREACH
 SELECT no_cuenta,
		cod_pagador,
		nombre
   INTO _no_cuenta,
		_cod_pagador,
		_nombre_pagador
   FROM cobcuhab

	{select count(*)
	  into _cant
	  from cliclien
	 where cod_cliente = _cod_pagador;

   if _cant > 0 then
   else
	 delete from cobcutas
	  where no_cuenta = _no_cuenta;

	 delete from cobcuhab
	  where no_cuenta = _no_cuenta;
   end if}
	let _no_cuenta = trim(_no_cuenta);
   	let _cant = length(_no_cuenta);

	if _no_cuenta[1] not between "0" and "9" and _cant >= 1 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[1]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[2] not between "0" and "9" and _cant >= 2 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[2]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[3] not between "0" and "9" and _cant >= 3 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[3]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[4] not between "0" and "9" and _cant >= 4 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[4]
			   WITH RESUME;
			let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[5] not between "0" and "9" and _cant >= 5 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[5]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[6] not between "0" and "9" and _cant >= 6 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[6]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[7] not between "0" and "9" and _cant >= 7 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[7]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[8] not between "0" and "9" and _cant >= 8 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[8]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[9] not between "0" and "9" and _cant >= 9 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[9]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[10] not between "0" and "9" and _cant >= 10 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[10]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[11] not between "0" and "9" and _cant >= 11 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[11]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[12] not between "0" and "9" and _cant >= 12 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[12]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[13] not between "0" and "9" and _cant >= 13 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[13]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[14] not between "0" and "9" and _cant >= 14 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[14]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[15] not between "0" and "9" and _cant >= 15 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[15]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[16] not between "0" and "9" and _cant >= 16 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[16]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	elif _no_cuenta[17] not between "0" and "9" and _cant >= 17 then

		RETURN _no_cuenta,
			   _nombre_pagador,
			   _cod_pagador,
			   _cant,
			   _no_cuenta[17]
			   WITH RESUME;
		let _cant = sp_amm14d(_no_cuenta);
	  continue foreach;
	else
		continue foreach;
    end if
		   	
END FOREACH
end

commit work;
END PROCEDURE