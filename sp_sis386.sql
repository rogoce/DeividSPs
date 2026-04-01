-- Despliega los correos de Gestores Activos
-- Creado     : 05/05/2011 - Autor: Henry Giron
DROP PROCEDURE sp_sis386;
create procedure "informix".sp_sis386()
returning char(8),   -- 1. Usuario 						  usuario     
		  char(100), -- 2. Correo del usuario 			  correo		
	      char(200), -- 3. Nombre completo del usuario	  nombre		
		  char(200), -- 4. Nombre Sucursal 				  sucursal	
		  char(3);   -- 5. Codigo Sucursal    	  		  cod_agencia	

DEFINE _usuario       char(8);   -- 1
DEFINE _correo		  char(100); -- 2
DEFINE _nombre		  char(200); -- 2
DEFINE _sucursal	  char(200); -- 2
DEFINE _cod_agencia	  char(3);

let    _correo   = "";
let    _nombre   = "";
let    _sucursal   = "";
let    _cod_agencia   = "";

SET ISOLATION TO DIRTY READ;
-- Seleccionamos todas las polizas que se renuevan del ramo de Salud
foreach 
	select distinct b.usuario ,
		   trim(b.e_mail),
		   b.descripcion ,
		   c.descripcion ,
		   b.codigo_agencia 
	 into _usuario,
	      _correo,
		  _nombre,
		  _sucursal,
		  _cod_agencia
	 from cobcobra a, 
	      segv05:insuser b, 
	      segv05:insagen c
	where a.usuario = b.usuario
	 	  and b.e_mail is not null
		  and b.status = 'A'
--		  and b.codigo_agencia = '010'
		  and b.codigo_compania = c.codigo_compania
		  and b.codigo_agencia = c.codigo_agencia
	order by b.codigo_agencia, b.usuario	
	  				 
		 return _usuario,    -- 1. Usuario 
		 		_correo,	 -- 2. Correo del usuario 
				_nombre,     -- 3. Nombre completo del usuario
				_sucursal,   -- 4. Nombre Sucursal 
				_cod_agencia -- 5. Codigo Sucursal 
		   with resume;
		   
end foreach;
		 return 'HGIRON',    -- 1. Usuario 
		 		'hgiron@asegurancon.com',	 -- 2. Correo del usuario 
				'Henry Giron',     -- 3. Nombre completo del usuario
				'OBARRIO',   -- 4. Nombre Sucursal 
				'001' -- 5. Codigo Sucursal 
		   with resume;
end procedure;
