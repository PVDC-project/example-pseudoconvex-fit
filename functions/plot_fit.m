function [] = plot_fit(X,Y,y,X_scale,Y_scale,fig)
figure(fig)
Xs = X * X_scale;
Ys = Y * Y_scale;
ys = y * Y_scale;
plot(Xs,Ys,'*','DisplayName','data')
hold on
plot(Xs,ys,'DisplayName','fit') 
xlabel('Torque [Nm]')
ylabel('Losses [W]')
grid on
legend('Location','Northwest')
end