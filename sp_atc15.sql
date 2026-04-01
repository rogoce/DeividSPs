-- Consulta de Clientes por No de Motor
-- Creado    : 06/02/2012 - Autor: Roman Gordon
-- SIS v.2.0 - d_ayuda_atc_motor_cte - DEIVID, S.A.

drop procedure sp_atc15;
create procedure sp_atc15(a_no_motor char(30))
returning char(10),	  
		  char(100),
		  char(30), 
		  char(10), 
		  char(50),
		  VARCHAR(255);

define _cedula              varchar(30);
define _nombre_cte			char(100);
define _direccion_1         char(50);
define _motor				char(30);
define _poliza              char(20);
define _cod_cliente  		char(10);
define _cod_ase		  		char(10);
define _telefono1           char(10);
define _cantidad			integer;
define _climalare           varchar(50);
define _desc_mala_ref       varchar(250);
define _cod_mala_refe       char(3);

--set debug file to "sp_atc12.trc"; 
--trace on;

create temp table temp_atc15
     						(no_poliza        char(10),
	      					 cod_contratante  char(10),
      			primary key (no_poliza,cod_contratante))
      			with no log;


set isolation to dirty read;

let _cedula			= null;
let _telefono1		= null;
let _direccion_1	= null;


--sacar informacion de la(s) poliza(s)

foreach
	select no_poliza
	  into _poliza
	  from emiauto
	 where trim(no_motor) = trim(a_no_motor)
	 order by no_poliza

	foreach
		select distinct(cod_contratante)
		  into _cod_cliente
		  from emipomae
		 where no_poliza = _poliza
		   and actualizado  = 1

		insert into temp_atc15							
							  (no_poliza,
					 		   cod_contratante)
			   			values(_poliza,
					 		   _cod_cliente );

	end foreach
end foreach

foreach
	select distinct(cod_contratante)
	  into _cod_cliente
	  from temp_atc15
 
	select nombre,
		   cedula,
		   telefono1,
		   direccion_1,
		   desc_mala_ref,
		   cod_mala_refe
	  into _nombre_cte,
		   _cedula,
		   _telefono1,
		   _direccion_1,
		   _desc_mala_ref,
		   _cod_mala_refe
	  from	cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _climalare
	  from climalare
	 where cod_mala_refe = _cod_mala_refe;

	if _climalare is null then	
		let _climalare = "";
	end if

	if _desc_mala_ref is null then	
		let _desc_mala_ref = "";
	end if
		
	 return _cod_cliente,
	 		_nombre_cte,
			_cedula,
			_telefono1,
			_direccion_1,
			trim(trim(_climalare) || " " || trim(_desc_mala_ref))
			with resume;
end foreach

drop table temp_atc15;
end procedure;