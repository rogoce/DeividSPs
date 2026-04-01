drop procedure sp2c_hg1;
create procedure sp2c_hg1()
returning	smallint		as cod_error,
			varchar(100)	as poliza,
			date			as cubierto_hasta;

define _mensaje				varchar(100);
define _error_isam			integer;
define _error				integer;
define _nombre			varchar(60);


define _no_documento		char(20);
DEFINE _cod_pagador		 	char(10);
define _no_tran integer;
define _no_cuenta			char(17);
define _nombre_cliente		char(100);
define _descripcion			char(100);
define _nombre_agente		char(50);
define _cod_agente			char(10);
define _no_poliza			char(10);

set isolation to dirty read;

set debug file to "sp_hg1.trc";
trace on;

--Query para crear la temporal
BEGIN WORK;
begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje,null;
end exception
let _nombre_cliente = "";
let _nombre_agente = "";
foreach
	select no_cuenta,no_tran,no_documento,nombre_pagador
	  into _no_cuenta,_no_tran,_no_documento,_nombre_cliente
	  from cobcutmp_temhg1

	  	let _no_poliza = sp_sis21(_no_documento);
{
		foreach		--Leer el detalle de ach
			select nombre
			  into _nombre_cliente
			  from cobcutas
			 where trim(no_cuenta) = trim(_no_cuenta)
			   and no_documento    = _no_documento

			exit foreach;
		end foreach
}
		select cod_pagador
		into _cod_pagador
		  from emipoliza
		 where no_documento = _no_documento;
{
		if _nombre_cliente is null or _nombre_cliente = "" then
			let _nombre_cliente = "";
			select upper(nombre)
			into _nombre_cliente
			from cliclien
			where cod_cliente = _cod_pagador;
		end if
}
			-- Descripcion de la remesa

	let _nombre_agente = "";

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		exit foreach;
	end foreach

	if _nombre_agente is null or _nombre_agente = "" then
		let _nombre_agente = "";
			let _descripcion = trim(_nombre_cliente) || "." || TRIM(_nombre_agente);
			else
				let _descripcion = trim(_nombre_cliente) || "/" || TRIM(_nombre_agente);

	end if


		 update cobcutmp_temhg1
		    set cod_pagador = _cod_pagador,
			motivo = _descripcion,
			periodo = '',
			motivo_rechazo  = ''
		 where no_tran = _no_tran;



	return _no_tran,_cod_pagador||'-'||_descripcion,null with resume;
end foreach
COMMIT WORK;
return 0,'Exito',null;

end
end procedure 
                                                                                                                                                                                                                                                      
