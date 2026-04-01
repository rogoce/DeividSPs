-- Pólizas de colectivo de vida para Palumbo
-- 
-- Creado    : 26/03/2019 - Autor: Amado Pérez M.
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE ap_act_cli;

CREATE PROCEDURE "informix".ap_act_cli()
returning integer;

define _no_poliza		char(10);
define _no_documento    char(20);
define _cod_status   	char(1);
define _cod_contratante	char(10);
define _nombre			varchar(100);
define _suma_asegurada  dec(16,2);
define _fecha_aniversario date;
define _sexo            char(1);
define _edad            smallint;
define _vigencia_inic   date;
define _status          char(10);


--set debug file to "sp_rwf12.trc";
--trace on;

--begin work;

let _edad = 0;
{foreach with hold
	select cod_cliente,
	       fecha_aniversario
	  into _cod_contratante,
	       _fecha_aniversario
	  from cliente3
	 	 
    update cliclien
	   set fecha_aniversario = _fecha_aniversario
     where cod_cliente = _cod_contratante;

	let _edad = _edad + 1;
end foreach
}
foreach with hold
	select cod_asegurado
	  into _cod_contratante
	  from emipouni
	 where no_poliza = '0001317697'
	 	 
    update cliclien
	   set e_mail = 'mensajeria@urenayurena.net'
     where cod_cliente = _cod_contratante
	   and (e_mail is null or trim(e_mail) = "");

	let _edad = _edad + 1;
end foreach

return _edad;
end procedure