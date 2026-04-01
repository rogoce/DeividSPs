-- Arreglar el sexo de los asegurados

-- Creado    : 29/06/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_pro169;

create procedure "informix".sp_pro169()
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _nombre_cliente	char(50);
define _sexo_deivid		char(1);

define _id				integer;
define _asegurado		char(50);
define _sexo			char(15);

-- Parte 1

foreach
 select	id,
        poliza,
		asegurado,
		sexo
   into _id,
        _no_documento,
		_asegurado,
		_sexo
   from deivid_tmp:saludsexo

	let _no_poliza = sp_sis21(_no_documento);

	foreach
	 select cod_asegurado
	   into _cod_cliente
	   from emipouni
	  where no_poliza = _no_poliza

		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_cliente;

		if _asegurado = _nombre_cliente then

			if _sexo = "Masculino" then
				let _sexo_deivid = "F";
			else
				let _sexo_deivid = "M";
			end if				

			update deivid_tmp:saludsexo
			   set cod_cliente = _cod_cliente,
			       sexo_deivid = _sexo_deivid
			 where id          = _id;

		end if

	end foreach

end foreach

-- Parte 2

foreach
 select	cod_cliente,
        sexo_deivid
   into _cod_cliente,
		_sexo_deivid
   from deivid_tmp:saludsexo

	update cliclien
	   set sexo        = _sexo_deivid
	 where cod_cliente = _cod_cliente;

end foreach

return 0, "Actualizacion Exitosa";

end procedure