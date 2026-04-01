-- Arreglar Gestion Sucursal Equivocada
-- 
-- Creado    : 03/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas024;
create procedure sp_cas024()
returning smallint,
          char(50);

define _no_documento	char(20);
define _cod_pagador		char(10);
define _no_poliza		char(10);
define _code_correg		char(5);
define _sucursal_origen	char(3);
define _cod_compania	char(3);
define _cod_cobrador	char(3);
define _cod_formapag	char(3);
define _cod_sucursal	char(3);
define _code_pais		char(3);
define _code_provincia	char(2);
define _code_distrito	char(2);
define _code_ciudad		char(2);
define _telefono1		char(1);
define _telefono2		char(1);
define _telefono3		char(1);
define _valor			smallint;

--set debug file to "sp_cas024.trc";
--trace on;
set isolation to dirty read;

let _cod_compania = "001";

--Procedimiento para actualizar los monto de las TCR /ACH en sus respectivos mantenimientos, una vez entre en vigor la vigencia
let _valor = sp_sis404();

foreach
	select cod_cliente
	  into _cod_pagador
	  from cascliente
	 where cod_gestion = "021"
	   --and cod_cliente = "25469"

{
	 select code_pais,	  
			code_provincia,
			code_ciudad,	  
			code_distrito, 
			code_correg
	   into _code_pais,	  
			_code_provincia,
			_code_ciudad,	  
			_code_distrito, 
			_code_correg	  
	   from cliclien
	  where cod_cliente = _cod_pagador;

	select cod_sucursal
	  into _cod_sucursal
	  from gencorr
	 where code_pais	   = _code_pais
	   and code_provincia  = _code_provincia
	   and code_ciudad	   = _code_ciudad
	   and code_distrito   = _code_distrito
	   and code_correg	   = _code_correg;
}

	let _cod_sucursal = null;

	foreach
		select no_documento
		  into _no_documento
		  from caspoliza
		 where cod_cliente = _cod_pagador

		let _no_poliza = sp_sis21(_no_documento);

		select sucursal_origen,
	           cod_formapag
		  into _sucursal_origen,
	           _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;

		select centro_costo
		  into _cod_sucursal
		  from insagen
		 where codigo_agencia  = _sucursal_origen
		   and codigo_compania = _cod_compania;    

		if  _cod_sucursal = "002" then  
			let _code_pais		= "001";
			let	_code_provincia	= "02";
			let	_code_ciudad  	= "12";
			let _code_distrito 	= "03";
			let	_code_correg	= "00105";
		elif  _cod_sucursal = "003" then
			let _code_pais		= "001";
			let	_code_provincia	= "05";
			let	_code_ciudad  	= "11";
			let _code_distrito 	= "05";
			let	_code_correg	= "00104";
		end if

		if  _cod_sucursal <> "001" then
			update cliclien
			   set code_pais      = _code_pais,
		     	   code_provincia = _code_provincia,
			   	   code_ciudad    = _code_ciudad,
			   	   code_distrito  = _code_distrito,
			       code_correg    = _code_correg
		     where cod_cliente    = _cod_pagador;
		end if

		exit foreach;
	end foreach

	if _cod_formapag = "022" then

		let _cod_sucursal   = "003";
		let _code_pais		= "001";
		let	_code_provincia	= "05";
		let	_code_ciudad  	= "11";
		let _code_distrito 	= "05";
		let	_code_correg	= "00104";

		update cliclien
		   set code_pais      = _code_pais,
	     	   code_provincia = _code_provincia,
		   	   code_ciudad    = _code_ciudad,
		   	   code_distrito  = _code_distrito,
		       code_correg    = _code_correg
	     where cod_cliente    = _cod_pagador;

	end if

	if _cod_formapag = "021" then

		let _cod_sucursal   = "002";
		let _code_pais		= "001";
		let	_code_provincia	= "02";
		let	_code_ciudad  	= "12";
		let _code_distrito 	= "03";
		let	_code_correg	= "00105";

		update cliclien
		   set code_pais      = _code_pais,
	     	   code_provincia = _code_provincia,
		   	   code_ciudad    = _code_ciudad,
		   	   code_distrito  = _code_distrito,
		       code_correg    = _code_correg
	     where cod_cliente    = _cod_pagador;

	end if

	if _cod_sucursal = "001" then
		let _cod_sucursal = null;
	end if

	if _cod_sucursal is null then

		select telefono1[1],	  
			   telefono2[2],
			   telefono3[3]
		  into _telefono1,	  
			   _telefono2,
			   _telefono3
		  from cliclien
		 where cod_cliente = _cod_pagador;

		if _telefono1 = "4" or _telefono2 = "4" or _telefono3 = "4" then

			let _cod_sucursal   = "002";
			let _code_pais		= "001";
			let	_code_provincia	= "02";
			let	_code_ciudad  	= "12";
			let _code_distrito 	= "03";
			let	_code_correg	= "00105";

			update cliclien
			   set code_pais      = _code_pais,
		     	   code_provincia = _code_provincia,
			   	   code_ciudad    = _code_ciudad,
			   	   code_distrito  = _code_distrito,
			       code_correg    = _code_correg
		     where cod_cliente    = _cod_pagador;
		end if
	end if

	if _cod_sucursal is null then

		select telefono1[1],	  
			   telefono2[2],
			   telefono3[3]
		  into _telefono1,	  
			   _telefono2,
			   _telefono3
		  from cliclien
		 where cod_cliente = _cod_pagador;

		if _telefono1 = "7" or _telefono2 = "7" or _telefono3 = "7" then

			let _cod_sucursal   = "003";
			let _code_pais		= "001";
			let	_code_provincia	= "05";
			let	_code_ciudad  	= "11";
			let _code_distrito 	= "05";
			let	_code_correg	= "00104";

			update cliclien
			   set code_pais      = _code_pais,
		     	   code_provincia = _code_provincia,
			   	   code_ciudad    = _code_ciudad,
			   	   code_distrito  = _code_distrito,
			       code_correg    = _code_correg
		     where cod_cliente    = _cod_pagador;
		end if
	end if

	{if _cod_sucursal is not null then

		if _cod_sucursal <> "001" then

			let _cod_cobrador = sp_cas006(_cod_sucursal, 1);

			update cascliente
			   set cod_cobrador = _cod_cobrador,
			       cod_gestion  = null
			 where cod_cliente  = _cod_pagador;
		end if
	end if}	 
end foreach



return 0,"Actualizacion Exitosa";

end procedure
