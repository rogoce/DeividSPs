
DROP procedure sp_jean09;
CREATE procedure sp_jean09()
RETURNING integer;

DEFINE _no_requis    CHAR(10);

foreach
	select distinct no_requis
	into _no_requis
	from chqctaux
	where no_requis in(
	select no_requis from chqchmae
	where origen_cheque = '8'
	and fecha_captura = today -1)
	and cod_auxiliar <> '05815'
	and cuenta[1,3] = '570'

	delete from chqctaux
	where no_requis = _no_requis
	and cod_auxiliar <> '05815';

end foreach

return 0;

END PROCEDURE;