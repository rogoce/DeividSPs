-- WorkFlow - Busqueda de Proveedores

-- Creado    : 26/08/2004 - Autor: Amado Perez  
			    
--drop procedure sp_rwf29;

create procedure "informix".sp_rwf29(a_valor varchar(100))
returning char(10),
		  char(100),
		  char(50);

define v_cod_asegurado		char(10);
define v_nombre_asegurado  	char(100);
define v_e_mail			    char(50);

SET ISOLATION TO DIRTY READ;

let a_valor = "%" || a_valor || "%";

foreach
	select cod_cliente,
	       nombre,
	       e_mail
	  into v_cod_asegurado,
	       v_nombre_asegurado,
		   v_e_mail
	  from cliclien
	 where nombre like a_valor

	return v_cod_asegurado,
		   v_nombre_asegurado,
		   v_e_mail
		   with resume;
end foreach

end procedure;
