-- Procedimiento que crea el registro de hojas para el archivo de documentos

-- Creado    : 31/08/2011 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_log003;

create procedure sp_log003(
_origen		smallint,
_instancia	char(10)
) returning char(20);

define _imp_num		char(20);

if _origen = 0 then   -- No Definido
	let _imp_num = null;

elif _origen = 1 then -- Instancia Therefore
	let _imp_num = null;

elif _origen = 2 then -- Digitalizacion Masiva
	let _imp_num = null;

elif _origen = 3 then -- Emision WEB
	let _imp_num = null;

elif _origen = 4 then -- Evaluaciones Salud
	let _imp_num = "ES - " || _instancia;

elif _origen = 5 then -- Renovacion Automatica
	let _imp_num = null;

else
	let _imp_num = null;
end if	

return _imp_num;

end procedure