-- Margen de Contribucion Minimo (MCM)
-- Procedimiento que carga los valores en las tablas control

-- Creado    : 21/04/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo027;

CREATE PROCEDURE "informix".sp_bo027()
returning integer,
          char(50);

define _ano				smallint;
define _cod_agruan		char(2);

define _cod_corredor	char(5);
define _cod_grupo		char(5);
define _cod_contrato	char(5);
define _sucursal_origen	char(3);
define _cod_ramo		char(3);
define _cod_vendedor	char(3);
define _nombre			char(50);

define _error_code		integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error_code, _error_isam, _error_desc
	return _error_code, _error_desc; 
end exception

-- Cargar la tabla del MCM por ramo

let _ano = 2006;

{
insert into deivid_bo:mcmmaram
select _ano,
       cod_ramo,
	   porc_mcm
  from prdramo;
}

-- Cargar los Valores Default (boagruan)

-- Para Accionistas

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "01"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

    foreach 
	 select cod_grupo,
	        nombre
	   into _cod_grupo,
	        _nombre
	   from cligrupo
	  where accionista = 1

		insert into deivid_bo:boagrusu
		values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	end foreach

end foreach

-- Para Grupo el Estado

let _cod_grupo = "00000";
 
foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "02"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "1000";

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

end foreach

-- Para Fronting

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "03"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

    foreach 
	 select cod_contrato,
	        nombre
	   into _cod_contrato,
	        _nombre
	   from reacomae
	  where fronting = 1

		insert into deivid_bo:boagrusu
		values (_ano, _cod_agruan, _cod_contrato, _nombre, _cod_contrato);

	end foreach

end foreach

-- Para Sucursales

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "04"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

{
	let _sucursal_origen = "051"; -- FASA

	select descripcion
	  into _nombre
	  from insagen
	 where codigo_agencia  = _sucursal_origen
	   and codigo_compania = "001";
	    	 
	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _sucursal_origen, _nombre, _sucursal_origen);

	let _sucursal_origen = "059"; -- General Representatives (Financiera Delta)
	 
	select descripcion
	  into _nombre
	  from insagen
	 where codigo_agencia  = _sucursal_origen
	   and codigo_compania = "001";

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _sucursal_origen, _nombre, _sucursal_origen);
}

end foreach

-- Para Grupos

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "05"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

	let _cod_grupo = "00063"; -- Multicredit

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "00069"; -- Multicredit

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "01004"; -- Multicredit

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "00106"; -- FASA

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "00064"; -- Financiera Delta

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

	let _cod_grupo = "01025"; -- Pacific Leasing

	 select nombre
	   into _nombre
	   from cligrupo
	  where cod_grupo = _cod_grupo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_grupo, _nombre, _cod_grupo);

end foreach

-- Para Corredores

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "06"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

	let _cod_corredor = "00035"; -- Ducruet

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00815"; -- Ducruet

{
	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;
}

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00141"; -- Uniseguros

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00875"; -- Waked

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _nombre = "INTERNATIONAL INSURANCE";

	let _cod_corredor = "00731"; -- Alberto Camacho

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "01100"; -- Beatriz Mirabal

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00636"; -- Jovani Mora

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00732"; -- Quita Paz

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00865"; -- Rogelio Becerra

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00218"; -- Kam

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00133"; -- Kam

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "01266"; -- Insurance Services

	 select nombre
	   into _nombre
	   from agtagent
	  where cod_agente = _cod_corredor;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00235"; -- Seguros ICT

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

	let _cod_corredor = "00705"; -- Seguros Globales

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_corredor, _nombre, _cod_corredor);

end foreach

-- Para Fianzas

let _cod_ramo = "008"; -- Fianzas

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "07"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

	 select nombre
	   into _nombre
	   from prdramo
	  where cod_ramo = _cod_ramo;

	insert into deivid_bo:boagrusu
	values (_ano, _cod_agruan, _cod_ramo, _nombre, _cod_ramo);

end foreach

-- Para Promotorias

foreach
 select cod_agruan,
        ano
   into _cod_agruan,
        _ano
   from deivid_bo:boagruan
  where cod_tipoagru = "08"

	delete from deivid_bo:boagrusu
     where ano        = _ano
       and cod_agruan = _cod_agruan;	

	foreach
	 select cod_vendedor,
	 		nombre
	   into _cod_vendedor,
	        _nombre
	   from agtvende

		insert into deivid_bo:boagrusu
		values (_ano, _cod_agruan, _cod_vendedor, _nombre, _cod_vendedor);

	end foreach

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure