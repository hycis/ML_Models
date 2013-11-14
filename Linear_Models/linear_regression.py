

import numpy as np
import pylab as pl
import matplotlib.pyplot as plt
from sklearn import linear_model
from sklearn import cross_validation

'''
author: Wu Zhenzhou
I use pyplot and scikit-learn for this project. Refer to scikit-learn api for more details
Reference: scikit-learn.org
'''

def load_X_y(dir_path = '../hw1-data/q1-data/'):
    
    with open(dir_path+"X.txt", 'r') as X_file:
        X = []
        line = X_file.readline()
        while line != "":
            row = map(float, line.split()) + [1]
            X.append(row)
            line = X_file.readline()
        X = np.asarray(X)
                
    with open(dir_path+'y.txt', 'r') as y_file: 
        y = []
        line = y_file.readline()
        while line != "":
            ele = map(float, line.split())
            y += ele
            line = y_file.readline()
        y = np.asarray(y)         
    
    return X, y
    
def qn_1a(X, y):
    
    print 'start Qn 1a'

    XT = np.transpose(X)
    XTX = np.dot(XT, X)

    
    print "the determinant of XTX is", np.linalg.det(XTX) , "which is non-zero, therefore X is non-singular"
    
    clf = linear_model.LinearRegression(fit_intercept=True)
    

    print 'generating graphs'
    
    for i in [0, 1, 2]:

        X_ones = np.reshape(X[:,i], newshape=(y.shape[0],1))
        clf.fit(X_ones, y)
        y_pred = clf.predict(X_ones)
        plot_graph("x_%s"%i, "y", "independent linear fit of y against feature x_%s"%i, 
                   "y_x%s.png"%i, 'tight', X[:,i], y, 'x', X[:,i], y_pred)
    
    std0 = np.std(X[:,0])
    mean0 = np.mean(X[:,0])
    
    std1 = np.std(X[:,1])
    mean1 = np.mean(X[:,1])
    
    std2 = np.std(X[:,2])
    mean2 = np.mean(X[:,2])
    
    print XTX
    XTX_inv = np.linalg.inv(XTX)
    
    clf_1 = linear_model.LinearRegression(fit_intercept=False)
    clf_1.fit(X, y)
    coef = clf_1.coef_
    Z_0 = coef[0] / (std0 * np.sqrt(XTX_inv[0][0]))
    Z_1 = coef[1] / (std1 * np.sqrt(XTX_inv[1][2]))
    Z_2 = coef[2] / (std2 * np.sqrt(XTX_inv[2][2]))

    print 'Z-score', Z_0, Z_1, Z_2
    
    print '(std_i, mean_i)', std0, mean0, std1, mean1, std2, mean2
    
    print 'Qn 1a ends'


def cross_valid_leave_one_out_errors(X, y, i):

    
    D = []
    length = len(X[0]) 
    for index in xrange(length-1):
        new_zeros = [0. for j in xrange(length)]
        new_zeros[index] = 1/np.max(X[:,index]) 
        D.append(new_zeros)
       
    zeros = [0. for k in xrange(length)]
    zeros[-1] = 1
    D.append(zeros)
    D = np.asarray(D)
        
    X_hat = np.dot(X, D)
    
    assert i < len(y)
    X_hat_i = X_hat[i] 
    X_hat = np.delete(X_hat, [i], axis=0)
    y_i = y[i]
    y = np.delete(y, [i], axis=0)
    
    X_hat_T_X_hat = np.dot(np.transpose(X_hat), X_hat)
    X_hat_T_X_hat_inv = np.linalg.inv(X_hat_T_X_hat)
    X_hat_T_y = np.dot(np.transpose(X_hat), y)
    w_hat = np.dot(X_hat_T_X_hat_inv, X_hat_T_y)
    error = y - np.dot(X_hat, w_hat)
    mean_sqr_train_error = np.dot(error, error) / len(y)
    
    error = y_i - np.dot(X_hat_i, w_hat)
    sqr_test_error = np.dot(error, error)
    return mean_sqr_train_error, sqr_test_error


def qn_1b(X, y):
    
    print 'start qn 1b'
    
    sum_train_error = 0
    sum_test_error = 0
    data_size = len(y)
    for i in xrange(data_size):

        mse_train, sqr_test_err = cross_valid_leave_one_out_errors(X, y, i)
        sum_train_error += mse_train
        sum_test_error += sqr_test_err
        
    print "mse_train_1b", sum_train_error / data_size
    print "sqr_test_err_1b", sum_test_error / data_size
    
    print 'end qn 1b'
   
def qn_1c(X, y):
    print 'start qn 1c'
    
    X_no_one = np.delete(X, [3], axis=1)
    X = np.append(X_no_one, X_no_one ** 2, axis=1)
    X = np.append(X, np.ones(shape=(X.shape[0],1), dtype=np.float), axis=1)
     
    sum_train_error = 0
    sum_test_error = 0
    data_size = len(y)
    for i in xrange(data_size):

        mse_train, sqr_test_err = cross_valid_leave_one_out_errors(X, y, i)
        sum_train_error += mse_train
        sum_test_error += sqr_test_err
        
    print "mse_train_1c", sum_train_error / data_size
    print "sqr_test_err_1c", sum_test_error / data_size
    
    print 'end qn 1c'
    

# Using scikit-learn library from http://scikit-learn.org/stable/modules/linear_model.html
# referece: http://scikit-learn.org/stable/auto_examples/linear_model/plot_ridge_path.html#example-linear-model-plot-ridge-path-py

def quadratic_X(X):
    X_no_one = np.delete(X, [3], axis=1)
    X = np.append(X_no_one, X_no_one ** 2, axis=1)
    X = np.append(X, np.ones(shape=(X.shape[0],1), dtype=np.float), axis=1)
    return X

def qn_1d(X, y, mode='zoom_in'):
    
    print 'start qn 1d'
    print 'starts generating graphs ...'
    X = quadratic_X(X)
    
    if mode is 'zoom_in':
        factor = 0.0001
    elif mode is 'zoom_out':
        factor = 0.01
    else:
        print 'choose mode as zoom in or zoom out'
        import sys
        sys.exit(1)
    
    alp = [x*factor for x in xrange(1,40)]
    clf = linear_model.Ridge(fit_intercept=False)
    
    coefs = []
    score_list = []
    for a in alp:
        clf.set_params(alpha=a)
        scores = cross_validation.cross_val_score(clf, X, y, cv=y.shape[0], scoring='mean_squared_error')
        clf.fit(X, y)
        coefs.append(clf.coef_)
        mean_score = np.abs(np.mean(scores))
        score_list.append(mean_score)

    ax = pl.gca()
    ax.set_color_cycle(['b', 'r', 'g', 'c', 'k', 'y', 'm'])
    line = ax.plot(alp, coefs)
    ax.set_yscale('symlog')
    pl.xlabel('lambda')
    pl.ylabel('weights')
    pl.legend(line, ['w6','w5', 'w4', 'w3', 'w2', 'w1','w0'], loc='upper left')
    pl.title('Ridge coefficients against weights')
    pl.axis('tight')
    pl.savefig('1d_weight_lambda_plot_%s.png'%mode) 
    pl.close()
    
    plot_graph('lambda', 'test_error', 'cross valid test error vs lambda',
               '1d_cv_test_error_lambda_%s.png'%mode, 'tight', alp, score_list)
    
    print 'min test error: ', np.min(np.asarray(score_list))

    
    print '1d_weight_lambda_plot.png and 1d_cv_test_error_lambda.png graphs generated'
    print 'end qn 1d'
    
def qn_1e(X, y, mode='zoom_in'):
    
    print 'start qn 1e'
    print 'starts generating graphs ...'
    
    X = quadratic_X(X)
    
    if mode is 'zoom_in':
        factor = 0.0005
    elif mode is 'zoom_out':
        factor = 0.01
    else:
        print 'choose mode as zoom in or zoom out'
        import sys
        sys.exit(1)
    
    alp = [x*factor for x in xrange(1,40)]
    clf = linear_model.Lasso(fit_intercept=False)
    
    coefs = []
    score_list = []
    for a in alp:
        clf.set_params(alpha=a)
        scores = cross_validation.cross_val_score(clf, X, y, cv=y.shape[0], scoring='mean_squared_error')
        clf.fit(X, y)
        coefs.append(clf.coef_)
        mean_score = np.abs(np.mean(scores))
        score_list.append(mean_score)

    ax = pl.gca()
    ax.set_color_cycle(['b', 'r', 'g', 'c', 'k', 'y', 'm'])
    line = ax.plot(alp, coefs)
    ax.set_yscale('symlog')
    pl.xlabel('lambda')
    pl.ylabel('weights')
    pl.legend(line, ['w6','w5', 'w4', 'w3', 'w2', 'w1','w0'], loc='upper left')
    pl.title('Lasso coefficients against weights')
    pl.axis('tight')
    pl.savefig('1e_weight_lambda_plot_lasso_%s.png'%mode) 
    pl.close()
    
    plot_graph('lambda', 'test_error', 'cross valid test error vs lambda', 
               '1e_cv_test_error_lambda_lasso_%s.png'%mode, 'tight', alp, score_list)
    
    print 'min test error: ', np.min(np.asarray(score_list))
    print '1e_weight_lambda_plot.png and 1e_cv_test_error_lambda.png graphs generated'
    print 'end qn 1e'
    
def plot_graph(x_label, y_label, title, save_path, axis='tight', *args):
    plt.plot(*args)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.title(title)
    plt.axis(axis)
    plt.savefig(save_path)
    plt.close()
    

def linear(X, y):
    clf = linear_model.LinearRegression()
    clf.fit(X, y)
    print clf.coef_
if __name__ == "__main__":
    X, y = load_X_y()

    print 'uncomment each function below to view results for each question'
    qn_1a(X, y)  
    qn_1b(X, y)
    qn_1c(X, y)
    qn_1d(X,y, 'zoom_in')
    qn_1d(X,y, 'zoom_out')
    qn_1e(X,y, 'zoom_out')
    qn_1e(X,y, 'zoom_in')
    
    
    