-- Procedimiento que carga los datos en la tabla de trimestres de reaseguro
 
-- Creado     :	12/11/2009 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rea001;		

create procedure "informix".sp_rea001()
returning integer,
		  char(100);

define _ano			smallint;
define _ano2		smallint;
define _mes			smallint;
define _per_ano		char(9);

define _trim		smallint;
define _nom_trim	char(50);

define _periodo1 	char(7);
define _periodo2	char(7);
define _periodo3	char(7);

set isolation to dirty read;

delete from reatrim;

for _ano = 2008 to 2050

	let _ano2    = _ano + 1;
	let _per_ano = _ano || "-" || _ano2;

	for _trim = 1 to 4

		if _trim = 1 then

			let _periodo1 = _ano || "-07";
			let _periodo2 = _ano || "-08";
			let _periodo3 = _ano || "-09";
		
			let _nom_trim = "1er Trimestre " || _per_ano; 

		elif _trim = 2 then

			let _periodo1 = _ano || "-10";
			let _periodo2 = _ano || "-11";
			let _periodo3 = _ano || "-12";
						
			let _nom_trim = "2do Trimestre " || _per_ano; 

		elif _trim = 3 then

			let _periodo1 = _ano2 || "-01";
			let _periodo2 = _ano2 || "-02";
			let _periodo3 = _ano2 || "-03";

			let _nom_trim = "3er Trimestre " || _per_ano; 

		elif _trim = 4 then

			let _periodo1 = _ano2 || "-04";
			let _periodo2 = _ano2 || "-05";
			let _periodo3 = _ano2 || "-06";

			let _nom_trim = "4to Trimestre " || _per_ano; 

		end if

		insert into reatrim
		values (_per_ano, _trim, _nom_trim, "A", "A", _periodo1, _periodo2, _periodo3);

	end for

end for

return 0, "Actualizacion Exitosa";

end procedure