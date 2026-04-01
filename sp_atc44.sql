-- Consulta de Clientes por No de Reclamo
-- Creado    : 06/02/2012 - Autor: Roman Gordon
-- SIS v.2.0 - d_ayuda_atc_motor_cte - DEIVID, S.A.

drop procedure sp_atc44;
create procedure sp_atc44(a_no_poliza char(10))
returning  SMALLINT, VARCHAR(255);

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

--set debug file to "sp_atc17.trc"; 
--trace on;

select cod_contratante
  into _cod_cliente
  from emipomae
 where no_poliza = a_no_poliza
   and actualizado  = 1;
 
select desc_mala_ref,
	   cod_mala_refe
  into _desc_mala_ref,
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

IF trim(_climalare) = "" and trim(_desc_mala_ref) = "" THEN
	return 0, "";
ELSE
	return 1, trim(trim(_climalare) || " " || trim(_desc_mala_ref));
END IF

end procedure;