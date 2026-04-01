-- Procedimiento busca quien aprueba las transacciones

-- Creado    : 07/12/2018 - Autor: Amado Perez  

drop procedure sp_rwf161;

create procedure sp_rwf161(a_no_tranrec char(10), a_cod_sucursal char(3)) 
returning varchar(255);

--define _suma_asegurada 	dec(16,2);
define _cod_aprobacion  char(3);
define _grupo           varchar(25);
define _cadena          varchar(255);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

If a_cod_sucursal = "001" Then
	let _cod_aprobacion = "002"
Else
	let _cod_aprobacion = "004"
End If

let _grupo = sp_cwf3(a_no_tranrec, _cod_aprobacion);

let _cadena = "";

If _grupo = "JEFE" Then	
	let _ciclo = 1;
	let _opcion = 2;
Elif _grupo = "TECNICO" Then	
	let _ciclo = 2;
	let _opcion = 3;
Elif _grupo = "TECNICO_2" Then	
	let _ciclo = 3;
	let _opcion = 5;
Elif _grupo = "GERENTE" Then	
	let _ciclo = 4;
	let _opcion = 4;
End If

end procedure