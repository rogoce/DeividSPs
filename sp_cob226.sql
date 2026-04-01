-- Procedure que Analiza las Remesas a nivel de chequera

-- Creado    : 28/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_cob226;

create procedure sp_cob226() 
returning char(10),
          char(3),
		  char(50),
		  char(3),
		  char(50),
		  char(1),
		  date,
		  dec(16,2),
		  char(8),
		  char(3),
		  char(50);

define _cod_chequera	char(3);
define _nombre_chequera	char(50);
define _cantidad		smallint;

define _no_remesa		char(10);
define _cod_sucursal	char(3);
define _cod_cobrador	char(3);
define _tipo_remesa		char(1);
define _fecha			date;
define _monto_chequeo	dec(16,2);
define _user_added		char(8);

define _nombre_sucursal	char(50);
define _nombre_cobrador	char(50);
define _periodo			char(7);

set isolation to dirty read;

let _periodo = "2010-01";

foreach
 select cod_chequera,
        nombre
   into _cod_chequera,
        _nombre_chequera
   from chqchequ
  where cod_banco = "146"

	 select	count(*)
	   into	_cantidad
	   from cobremae
	  where periodo     >= _periodo
	    and cod_chequera = _cod_chequera
	    and actualizado  = 1;

--	let _cantidad = 0;

	if _cantidad = 0 then

		return "00000",
		       "",
			   "NO HAY REGISTROS",
			   "",
			   "",
			   "",
			   null,
			   0.00,
			   "",
			   _cod_chequera,
			   _nombre_chequera
			   with resume;

	else

		foreach
		 select	cod_cobrador,
				cod_sucursal,
				tipo_remesa,
--				fecha,
				sum(monto_chequeo)
--				user_added
		   into	_cod_cobrador,
				_cod_sucursal,
				_tipo_remesa,
--				_fecha,
				_monto_chequeo
--				_user_added
		   from cobremae
		  where periodo     >= _periodo
		    and cod_chequera = _cod_chequera
		    and actualizado  = 1
--			and tipo_remesa  = "C"
		  group by cod_sucursal, tipo_remesa, cod_cobrador
		  order by cod_sucursal, tipo_remesa, cod_cobrador

{
		 select	no_remesa,
				cod_cobrador,
				cod_sucursal,
				tipo_remesa,
				fecha,
				monto_chequeo,
				user_added
		   into	_no_remesa,
				_cod_cobrador,
				_cod_sucursal,
				_tipo_remesa,
				_fecha,
				_monto_chequeo,
				_user_added
		   from cobremae
		  where periodo     >= _periodo
		    and cod_chequera = _cod_chequera
		    and actualizado  = 1
		  group by 
}

			let _no_remesa  = "00000";
			let _fecha      = null;
			let _user_added = null;

			select descripcion
			  into _nombre_sucursal
			  from insagen
			 where codigo_agencia = _cod_sucursal;

			select nombre
			  into _nombre_cobrador
			  from cobcobra
			 where cod_cobrador = _cod_cobrador;
			 
			 return _no_remesa,
			        _cod_sucursal,
					_nombre_sucursal,
					_cod_cobrador,
					_nombre_cobrador,
					_tipo_remesa,
					_fecha,
					_monto_chequeo,
					_user_added,
					_cod_chequera,
					_nombre_chequera
					with resume;

		end foreach

	end if

end foreach

end procedure
