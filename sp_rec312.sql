-- Procedure que actualiza la requisiciones cuando hay excepcion

-- AmadoPerez 10/01/2017


drop procedure sp_rec312;

create procedure sp_rec312(a_usuario char(8))
RETURNING smallint;

define _codigo_perfil	char(3);
define _cnt				smallint;

set isolation to dirty read;
--SET LOCK MODE TO WAIT;

 let _cnt = 0; 
 
  SELECT Count(*)
	 INTO _cnt
	 FROM insauca  
	WHERE 	(insauca.usuario                 = a_usuario)    AND
			(insauca.aplicacion             = 'REC') AND
			(insauca.version                 = '02')    AND
			(insauca.status                 = 'A')    AND
			(insauca.tipo_autorizacion = '20');  


{select codigo_perfil
  into _codigo_perfil
  from insuser
 where usuario = a_usuario;
 
 let _cnt = 0; 
 
 select count(*)
   into _cnt
   from inspefi
  where codigo_perfil =_codigo_perfil
    and (descripcion like 'Gerente%'
	 or descripcion like 'Subgerente%');
}	 
  if _cnt is null then
	let _cnt = 0;
  end if
 	 
  	 
RETURN _cnt;

end procedure