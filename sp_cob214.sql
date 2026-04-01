-- Procedimiento que Genera los pagos en suspenso para una Remesa

-- Creado    : 09/09/2004 - Autor: Armando Moreno
-- Modificado: 30/09/2004 - Autor: Armando Moreno

-- SIS v.2.0 - DEIVID, S.A.

create procedure sp_cob214(
a_no_remesa	char(10)
) returning integer,
            char(50);

define _doc_suspenso	char(20);
define _monto			dec(16,2);
define _fecha			date;
define _nombre_agente	char(50);
define _nombre_cliente	char(50);
define a_user			char(8);

select recibi_de,
       user_posteo
  into _nombre_agente,
       a_user
  from cobremae
 where no_remesa = a_no_remesa;

foreach
 select	doc_remesa,
        monto,
		fecha,
		desc_remesa
   into	_doc_suspenso,
        _monto,
		_fecha,
		_nombre_cliente
   from cobredet
  where no_remesa = a_no_remesa
    and tipo_mov  = 'E'

	INSERT INTO cobsuspe(
	doc_suspenso,
	cod_compania,
	cod_sucursal,
	monto,
	fecha,
	coaseguro,
	asegurado,
	poliza,
	ramo,
	actualizado,
	user_added,
	date_added
	)
	VALUES(
    _doc_suspenso,
    "001",
    "001",
    _monto,
	_fecha,
	_nombre_agente,
	_nombre_cliente,
    null,
	null,
    1,
	a_user,
	_fecha
	);

end foreach

return 0, "Actualizacion Exitosa";

end procedure