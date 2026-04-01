-- Procedimiento que busca si hay registro en recterce 
-- Creado    : 06/12/2011 - Autor: Amado Perez  

drop procedure sp_rwf99;

create procedure sp_rwf99(a_reclamo char(10), a_tercero char(10)) 
returning char(10),
          char(30),
		  char(10),
		  varchar(255),
		  char(5),
		  char(5),
		  char(10),
		  integer,
		  varchar(100),
		  varchar(100),
		  varchar(50),
		  varchar(50),
		  varchar(30);

define _no_motor 	  char(30);
define _cod_conductor char(10);
define _descripcion   varchar(255);
define _cod_marca 	  char(5);
define _cod_modelo 	  char(5);
define _placa 		  char(10);
define _ano_auto	  integer;
define _tercero_n	  varchar(100);
define _conductor_n	  varchar(100);
define _marca_n		  varchar(50);
define _modelo_n	  varchar(50);
define _no_chasis	  varchar(30);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

select a.no_motor, 
       a.cod_conductor, 
       a.descripcion, 
       a.cod_marca, 
       a.cod_modelo, 
       a.placa, 
       a.ano_auto,
	   a.no_chasis
  into _no_motor, 
  	   _cod_conductor,
  	   _descripcion, 
  	   _cod_marca, 
  	   _cod_modelo, 
  	   _placa, 
   	   _ano_auto,
	   _no_chasis
  from recterce a 
 where a.no_reclamo = a_reclamo 
   and a.cod_tercero = a_tercero; 

select nombre
  into _tercero_n
  from cliclien
 where cod_cliente = a_tercero;

select nombre
  into _conductor_n
  from cliclien
 where cod_cliente = _cod_conductor;

select nombre
  into _marca_n
  from emimarca
 where cod_marca = _cod_marca;

select nombre
  into _modelo_n
  from emimodel
 where cod_marca = _cod_marca
   and cod_modelo = _cod_modelo;

return a_tercero,
       _no_motor, 	 
	   _cod_conductor,
	   _descripcion,  
	   _cod_marca, 	 
	   _cod_modelo, 	 
	   _placa, 		 
	   _ano_auto,
	   _tercero_n,	 
	   _conductor_n,
	   _marca_n,
	   _modelo_n,
	   _no_chasis;

end procedure