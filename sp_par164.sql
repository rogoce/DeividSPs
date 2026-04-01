-- Reporte de Simulacion de Registros Contables

-- Creado    : 30/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par164;

create procedure sp_par164(a_cod_producto char(10))

define _anos			smallint;

define _cod_producto	char(5);
define _edad			smallint;
define _sexo			char(1);
define _fumador			smallint;
define _tarifa			dec(16,3);


{
delete from prdtavid 
 where cod_producto = a_cod_producto;

-- Mujer No Fumador

for _anos = 18 to 80

	insert into prdtavid(
	cod_producto,
	edad,
	sexo,
	fumador,
	tarifa
	)
	values(
	a_cod_producto,
	_anos,
	"M",
	0,
	0.0000
	);

end for

-- Mujer Fumador

insert into prdtavid(
cod_producto,
edad,
sexo,
fumador,
tarifa
)
select 
cod_producto,
edad,
"M",
1,
tarifa
 from prdtavid
where cod_producto = a_cod_producto
  and sexo         = "M"
  and fumador      = 0;
	   
-- Hombre No Fumador

insert into prdtavid(
cod_producto,
edad,
sexo,
fumador,
tarifa
)
select 
cod_producto,
edad,
"H",
0,
tarifa
 from prdtavid
where cod_producto = a_cod_producto
  and sexo         = "M"
  and fumador      = 0;

-- Hombre Fumador

insert into prdtavid(
cod_producto,
edad,
sexo,
fumador,
tarifa
)
select 
cod_producto,
edad,
"H",
1,
tarifa
 from prdtavid
where cod_producto = a_cod_producto
  and sexo         = "M"
  and fumador      = 0;
}

foreach
 select trim(producto),
		edad,
		trim(sexo),
		fumador,
		tarifa
   into _cod_producto,
		_edad,		
		_sexo,		
		_fumador,		
		_tarifa
   from tarvida
   
	update prdtavid
	   set tarifa       = _tarifa
	 where cod_producto = _cod_producto
	   and edad         = _edad
	   and sexo         = _sexo
	   and fumador      = _fumador;

end foreach				

end procedure

