
-- Procedimiento para asegurado y dependientes
-- Modificado: HGIRON Fecha: 16042020
--  execute procedure sp_rec83des('1819-99900-01','01229') 
DROP PROCEDURE sp_rec83des_1;
CREATE PROCEDURE "informix".sp_rec83des_1(a_no_documento char(20),a_no_unidad CHAR(5),a_numrecla	char(20),a_cod_cliente char(10),a_tran char(10) default '*')

returning char(10) as cod_cliente,
		  varchar(100) as nombre,
		  char(4) as ano,		  
		  decimal(16,2) as monto_deducible,
		  decimal(16,2) as monto_deducible2,
		  decimal(16,2) as monto_coaseguro,
		  decimal(16,2) as monto_coaseguro2;
		  

define _cod_cliente			 char(10);
define _nombre               varchar(100);
define _ano2                 integer;
define _ano 			     char(4);
define _ano_gestionado	     char(4);
define _monto_deducible      decimal(16,2);
define _monto_deducible2     decimal(16,2);
define _monto_coaseguro      decimal(16,2);
define _monto_coaseguro2     decimal(16,2);


SET ISOLATION TO DIRTY READ;

foreach         
 select distinct year(b.fecha_factura)
   into _ano2
   from recrcmae  a,rectrmae b
  where	b.no_reclamo   = a.no_reclamo 
    and a.actualizado  = 1    
	and b.actualizado  = 1
	and a.numrecla     = a_numrecla
    and a.no_documento = a_no_documento	
	and b.transaccion  matches a_tran
    and b.fecha_factura is not null
	
	let _ano_gestionado = _ano2;
	
	--if a_tran = '*' then
	--   let a_cod_cliente = '*';
	--end if

   foreach
	 SELECT a.cod_cliente,
			b.nombre, 
			a.ano, 
			a.monto_deducible, 
			a.monto_deducible2, 
			a.monto_coaseguro, 
			a.monto_coaseguro2
	   into _cod_cliente,
			_nombre, 
			_ano, 
			_monto_deducible, 
			_monto_deducible2, 
			_monto_coaseguro, 
			_monto_coaseguro2
	   FROM recacuan a
		 INNER JOIN cliclien b  On a.cod_cliente = b.cod_cliente
		WHERE  no_documento =  a_no_documento  --'1819-99900-01'
		AND no_unidad = a_no_unidad  --'01229'
		AND a.cod_cliente matches a_cod_cliente --'513801'
		AND a.ano = _ano_gestionado --'2019'
  ORDER BY ano ASC,cod_cliente asc			 
		 
	     return _cod_cliente,
			_nombre, 
			_ano, 
			_monto_deducible, 
			_monto_deducible2, 
			_monto_coaseguro, 
			_monto_coaseguro2
		   with resume;	
		   
	end foreach
end foreach

END PROCEDURE
