-- Procedure que valida la cuenta ingresada en el Catalogo del Mayor
-- Creado    : 22/02/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_sac174;

create procedure sp_sac174(a_cta_cuenta char(25))
returning smallint,char(255);

define _est_nivel			char(1);
define _est_posinicial		smallint;
define _est_posfinal		smallint;
define nivel1				smallint;
define indice, pos1, pos2   smallint;

define _cta_nivel			char(1);
define _largo				smallint;
define work_cta				char(12);
define l_codigo				smallint;
define mensaje_error		char(255);

define wcta_nivel			char(1);
define wcta_tippartida	    char(1);
define wcta_recibe		    char(1);
define wcta_auxiliar	    char(1);
define i_aux                smallint;
define i_rec                smallint;

--set debug file to "sp_sac174.trc";
--trace on;

let _largo = length(a_cta_cuenta);
let i_aux = 0;
let i_rec = 0;

let _cta_nivel = 0;
let l_codigo = 0;
let mensaje_error = "Validacion Satisfactoria.";

foreach
 select est_nivel,
 		est_posinicial,
 		est_posfinal
   into _est_nivel,
 		_est_posinicial,
 		_est_posfinal
   from cglestructura

	if _largo >= _est_posinicial and
		_largo <= _est_posfinal  then

		let _cta_nivel = _est_nivel;
		exit foreach;
	end if

end foreach

if _cta_nivel = 0 then
	let l_codigo = 1;
	let mensaje_error = "No existe nivel en la estructura del catalogo para esta cuenta "|| trim(a_cta_cuenta) ;
end if

if l_codigo = 0 then 

	if _cta_nivel = 1 then
		let _cta_nivel = 2;
	end if

	let nivel1 = _cta_nivel - 1 ;
	FOR indice = nivel1 TO 1 STEP -1

		SELECT est_posinicial, est_posfinal INTO pos1, pos2
		FROM cglestructura
		WHERE est_nivel = indice;

		if pos1 IS NULL then
			let l_codigo = 1;
			let mensaje_error = "Para la Cuenta "||trim(a_cta_cuenta)||" No existe el nivel "|| indice ;
			EXIT FOR ;
		end if

		if pos2 IS NULL then
			let l_codigo = 1;
			let mensaje_error = "Para la Cuenta "||trim(a_cta_cuenta)||" No existe el nivel "|| indice ;
			EXIT FOR ;
		end if

		LET work_cta = substring(a_cta_cuenta from 1 for pos2);

		SELECT cta_nivel, cta_tippartida, cta_recibe, cta_auxiliar
		 INTO wcta_nivel, wcta_tippartida, wcta_recibe, wcta_auxiliar
		 FROM cglcuentas
		WHERE cta_cuenta = work_cta;

		if wcta_nivel IS NULL and _largo <> 3 then
			let l_codigo = 1;
			let mensaje_error =  "No Existe la Cuenta " || trim(work_cta)||", nivel anterior "||indice ;
			EXIT FOR ;
		end if

		if wcta_recibe = "S"  and _largo <> 3 then 
			let l_codigo = 1;
			let mensaje_error =  "Esta Cuenta no puede ser adicionada, La cuenta " || trim(work_cta)||" recibe movimiento." ;
			EXIT FOR ;
		end if

	END FOR

end if

--if l_codigo = 1 then 
	return l_codigo,mensaje_error;
--end if

end procedure 


