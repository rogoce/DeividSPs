-- Procedimiento busca quien aprueba las transacciones

-- Creado    : 07/12/2018 - Autor: Amado Perez  

drop procedure sp_rwf163;

create procedure sp_rwf163(a_cod_compania char(3), a_cod_sucursal char(3)) 
returning char(1);

--define _suma_asegurada 	dec(16,2);
define _valor_parametro       char(1);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

let _valor_parametro = "0";

  SELECT inspaag.valor_parametro 
    INTO _valor_parametro  
    FROM inspaag  
   WHERE inspaag.aplicacion = 'REC'
     AND inspaag.codigo_parametro = 'activa_yoseguro'
     AND inspaag.codigo_compania = a_cod_compania  
     AND inspaag.codigo_agencia = a_cod_sucursal;
	 
 if _valor_parametro is null or trim(_valor_parametro) = "" then
	let _valor_parametro = "0";
 end if 
  
  return _valor_parametro;

end procedure