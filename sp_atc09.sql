-- Retorna los Reclamos de Una Poliza
-- 
-- Creado    : 17/07/2008 - Autor: Armando Moreno M.
-- Modificado: 17/07/2008 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_atc09;

create procedure sp_atc09(a_cod_tercero char(10))
returning char(18),
          char(5),
          char(50),
          char(5),
          char(50),
		  char(10),
		  smallint;

define _no_reclamo		char(10);
define _numrecla		char(20);
define _ano_auto		smallint;
define _placa    		char(10);
define _n_marca			char(50);
define _n_modelo		char(50);
define _cod_marca       char(5);
define _cod_modelo      char(5);

let _n_marca = "";
let _n_modelo = "";

foreach
 select no_reclamo,
        cod_marca,
		cod_modelo,
		placa,
		ano_auto
   into	_no_reclamo,
        _cod_marca,
		_cod_modelo,
		_placa,
		_ano_auto
   from recterce
  where	cod_tercero = a_cod_tercero

 	select numrecla
	  into _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	if _cod_marca is null then
		let _cod_marca = "";
	else
		select nombre
		  into _n_marca
		  from emimarca
		 where cod_marca = _cod_marca;
	end if

	if _cod_modelo is null then
		let _cod_modelo = "";
	else
		select nombre
		  into _n_modelo
		  from emimodel
		 where cod_marca  = _cod_marca
		   and cod_modelo = _cod_modelo;
	end if


	return _numrecla,
		   _cod_marca,
		   _n_marca,
		   _cod_modelo,
		   _n_modelo,
		   _placa,
		   _ano_auto
		   with resume;

end foreach

end procedure
