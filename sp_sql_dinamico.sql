-- Procedure que borra los datos de chqpayasien y chqpaydet
-- Creado: 14/06/2012	- Autor: Roman Gordon

--	0,256	= CHAR 
--	1		= SMALLINT 
--	2,258	= INTEGER 
--	3		= FLOAT 
--	4		= SMALLFLOAT 
--	5,261	= DECIMAL 
--	6		= SERIAL * 
--	7		= DATE 
--	8		= MONEY 
--	9		= NULL 
--	10		= DATETIME 
--	11		= BYTE 
--	12		= TEXT	
--	13,269	= VARCHAR 
--	14		= INTERVAL 
--	15		= NCHAR 
--	16		= NVARCHAR 
--	17		= INT8 
--	18		= SERIAL8 * 
--	19		= SET 
--	20		= MULTISET 
--	21		= LIST 
--	22		= Unnamed ROW 
--	40		= Variable-length 
--	4118	= Named ROW


 													   
drop procedure sp_rrh03;

create procedure sp_rrh03(a_num_planilla char(10))
returning integer,
          char(100);

define _sqlsyntax	char(100);
define _sqlwhere	char(30);
define _colname		char(20);
define _numero		char(10);
define _renglon		smallint;
define _coltype		smallint;
define _cant		integer;
define _error		integer;															

--set debug file to "sp_rrh02.trc";
--trace on;

begin
on exception set _error
	return _error, "Error Borrar Carga de Pagos Externos.";
end exception

let _nombre_empleado	= '';
let _cod_empleado		= '';
let _cedula_emp			= '';
let _num_ach			= '';
let _cuenta				= '';
let _reglon				= 0;
let _no_cheque			= 0;
let _monto				= 0.00;

select tabid
  into _tabid
  from systables
 where tabname = 'chqpaydet';

foreach
	select colname,
		   coltype	
	  into _colname,
		   _coltype	
	  from syscolumns
	 where tabid = _tabid

	if _coltype in (0,13,256,269) then

		let _sqlwhere = 'where ' || trim(_colname) || ' is null';

	elif _coltype in (5,261) then

		let _sqlwhere = 'where ' || trim(_colname) || ' = 0.00';

	elif _coltype in (2,258) then

		let _sqlwhere = 'where ' || trim(_colname) || ' = 0';

	end if

	let _sqlsyntax = 'Select ' || trim(_colname) || ' from chqpaydet ' || trim(_sqlwhere);

   	prepare xsql from _sqlsyntax;	
	declare xcur cursor for xsql;	 
	open xcur;
	while (1 = 1)
		fetch xcur into	_no_tarjeta_comp,	
						_no_documento,
						_nombre,
						_monto; 

		if (sqlcode = 100) then
			exit;
		end if

		if (sqlcode != 100) then
			
		else
			exit;
		end if
	end while
	close xcur;	
	free xcur;
	free xsql;		
end foreach


	