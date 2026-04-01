-- Procedure que se utiliza para crear clientes

--drop procedure sp_sis82;

create procedure sp_sis82()
returning integer;

define _error	integer;

begin 
on exception set _error
	return _error;
end exception

insert into cliclien
select *
  from tmp_cliente;

end 

return 0;

end procedure